import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:vehicle_me/Models/Auction.dart';
import 'package:vehicle_me/Models/User.dart';
import 'market_tab.dart';
import 'chat_tab.dart';
import 'profile_tab.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'services_tab.dart';
import 'forum_tab.dart'; 
import 'package:vehicle_me/config.dart';
import 'package:vehicle_me/Services/chat_service.dart';

class HomePage extends StatefulWidget {
  final String authToken;

  HomePage(this.authToken);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  UserRegistration _userData = UserRegistration.empty();
  late Timer _tokenValidityTimer;
  List<Map<String, dynamic>> _lastChats = []; // Add this line

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    // Set up a timer to check token validity every 31 minutes
    _tokenValidityTimer = Timer.periodic(Duration(minutes: 31), (timer) {
      _checkTokenValidity();
    });
  }

  @override
  void dispose() {
    _tokenValidityTimer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _loadUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$currentIP/users/user/profile'),
        headers: {'Authorization': 'Bearer ${widget.authToken}'},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          _userData = UserRegistration.fromJson(userData);
        });
        _loadLastChats(); // Load chats after loading user profile
      } else {
        _handleError('Failed to load user profile (${response.statusCode})');
      }
    } catch (e) {
      _handleError('An error occurred. Please try again later.');
    }
  }

  void _loadLastChats() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.100:8000/ws/last-chats/${_userData.vehicle.carId}'), // Corrected carID reference
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
        },
      );
      if (response.statusCode == 200) {
        final chats = List<Map<String, dynamic>>.from(json.decode(response.body));
        final Map<String, Map<String, dynamic>> uniqueChats = {};

        for (var chat in chats) {
          final chatPartner = chat['sender'] == _userData.vehicle.carId
              ? chat['receiver']
              : chat['sender'];

          if (!uniqueChats.containsKey(chatPartner) || (uniqueChats[chatPartner]?['timestamp']?.compareTo(chat['timestamp']) ?? -1) < 0) {
            uniqueChats[chatPartner] = chat;
          }
        }

        setState(() {
          _lastChats = uniqueChats.values.toList();
          _lastChats.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        });
      } else {
        print('Failed to load last chats');
      }
    } catch (e) {
      print('Failed to load last chats: $e');
    }
  }

  void _checkTokenValidity() async {
    try {
      final response = await http.get(
        Uri.parse('$currentIP/auth/protected'),
        headers: {'Authorization': 'Bearer ${widget.authToken}'},
      );

      if (response.statusCode == 404 || response.statusCode == 401) {
        _handleLogout();
      }
    } catch (e) {
      _handleError('An error occurred. Please try again later.');
    }
  }

  void _handleError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    dispose();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    setState(() {
      _userData = UserRegistration.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'TeleCar',
          style: TextStyle(
            fontFamily: 'Lobster', // Apply the custom font
            fontSize: 38,
            color: Colors.white,
          ),
        ),
      ),
      body: _buildTabContent(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.deepPurple,
        currentIndex: _currentIndex,
        unselectedItemColor: Colors.deepPurple.shade200,
        selectedItemColor: Colors.deepPurple,
        useLegacyColorScheme: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_repair),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Forum',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentIndex) {
      case 0:
        return ChatTab(
          authToken: widget.authToken,
          userData: _userData,
          users: [],
          lastChats: _lastChats, // Pass the last chats to ChatTab
        );
      case 1:
        return MarketTab();
      case 2:
        return ProfileTab(
          authToken: widget.authToken,
          user: _userData,
        );
      case 3:
        return ServicesPage(
          authToken: widget.authToken,
          carId: _userData.vehicle.carId,
          user: _userData,
        );
      case 4:
        return ForumPage(authToken: widget.authToken,
          user: _userData,);
      default:
        return Container();
    }
  }
}
