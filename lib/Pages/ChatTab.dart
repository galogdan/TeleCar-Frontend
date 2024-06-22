import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:vehicle_me/Models/User.dart';
import 'chat_screen.dart';
import 'package:vehicle_me/config.dart';

class ChatTab extends StatefulWidget {
  final String authToken;
  final UserRegistration userData;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> lastChats;

  ChatTab({required this.authToken, required this.userData, required this.users, required this.lastChats, Key? key}) : super(key: key);

  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final TextEditingController _carIdController = TextEditingController();
  List<Map<String, dynamic>> _lastChats = [];
  String _errorMessage = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _lastChats = widget.lastChats;
    if (widget.userData.vehicle.carId != '') {
      _loadLastChats();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _loadLastChats();
    });
  }

  Future<void> _loadLastChats() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.100:8000/ws/last-chats/${widget.userData.vehicle.carId}'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
        },
      );
      if (response.statusCode == 200) {
        final chats = List<Map<String, dynamic>>.from(json.decode(response.body));
        final Map<String, Map<String, dynamic>> uniqueChats = {};

        for (var chat in chats) {
          final chatPartner = chat['sender'] == widget.userData.vehicle.carId
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

  Future<bool> _checkCarIdExists(String carId) async {
    try {
      final response = await http.get(
        Uri.parse('$currentIP/ws/users/$carId'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }

  void _onSearchPressed() async {
    final carId = _carIdController.text.trim();
    if (carId.isNotEmpty) {
      final carIdExists = await _checkCarIdExists(carId);
      if (carIdExists) {
        setState(() {
          _errorMessage = '';
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              authToken: widget.authToken,
              userData: widget.userData,
              carId: carId,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Car ID does not exist.';
        });
      }
    }
  }

  // Method to update the last chats
  void updateLastChats(List<Map<String, dynamic>> newLastChats) {
    setState(() {
      _lastChats = newLastChats;
    });
  }

  String _truncateMessage(String message) {
    const int maxLength = 50;
    if (message.length > maxLength) {
      return '${message.substring(0, maxLength)}...';
    }
    return message;
  }

  Future<void> _deleteChat(String chatPartner, int index) async {
    final response = await http.delete(
      Uri.parse('http://192.168.1.100:8000/ws/chats/${widget.userData.vehicle.carId}/$chatPartner'),
      headers: {
        'Authorization': 'Bearer ${widget.authToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _lastChats.removeAt(index);
      });
    } else {
      print('Failed to delete chat');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
      title: Text(
      'Chats',
      style: TextStyle(
        fontFamily: 'Oswald', // Apply the custom font
        fontSize: 28,
        color: Colors.white,
         ),
       ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _carIdController,
                        decoration: InputDecoration(
                          hintText: 'Enter car ID',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _onSearchPressed,
                    ),
                  ],
                ),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _lastChats.length,
              itemBuilder: (context, index) {
                final chat = _lastChats[index];
                final chatPartner = chat['sender'] == widget.userData.vehicle.carId
                    ? chat['receiver']
                    : chat['sender'];
                return ListTile(
                  title: Text(chatPartner),
                  subtitle: Text(_truncateMessage(chat['message'])),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await _deleteChat(chatPartner, index);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          authToken: widget.authToken,
                          userData: widget.userData,
                          carId: chatPartner,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
