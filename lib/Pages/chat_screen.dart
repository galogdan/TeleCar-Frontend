import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vehicle_me/Models/User.dart';
import 'package:vehicle_me/config.dart';
import 'package:vehicle_me/Pages/Services/PersonalInfoPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String authToken;
  final UserRegistration userData;
  final String carId;

  ChatScreen({
    required this.authToken,
    required this.userData,
    required this.carId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late WebSocketChannel channel;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    if (widget.userData.vehicle != null) {
      initializeWebSocket();
      _fetchMessages();
    } else {
      print('Error: userData.vehicle is null');
    }
  }

  void initializeWebSocket() {
    final url = 'ws://192.168.1.100:8000/ws/ws/${widget.userData.vehicle.carId}/${widget.carId}';
    print('Connecting to WebSocket URL: $url');
    channel = IOWebSocketChannel.connect(Uri.parse(url));
    channel.stream.listen((message) {
      final decodedMessage = json.decode(message);
      setState(() {
        _messages.add({
          'type': 'received',
          'sender': decodedMessage['sender'],
          'message': decodedMessage['message'],
          'timestamp': decodedMessage['timestamp']
        });
        _messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      });
      _scrollToBottom();
    });
  }

  Future<void> sendMessage(String message) async {
    if (message.isNotEmpty) {
      final messageData = {
        'sender': widget.userData.vehicle.carId,
        'receiver': widget.carId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      };
      final encodedMessage = json.encode(messageData);
      channel.sink.add(encodedMessage);
      setState(() {
        _messages.add({
          'type': 'sent',
          'sender': widget.userData.vehicle.carId,
          'message': message,
          'timestamp': messageData['timestamp']
        });
        _messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      });
      _controller.clear();
      _scrollToBottom();
    }
  }

  Future<void> sendPersonalInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final fullName = prefs.getString('fullName') ?? '';
    final address = prefs.getString('address') ?? '';
    final idNumber = prefs.getString('idNumber') ?? '';
    final driverLicenseNumber = prefs.getString('driverLicenseNumber') ?? '';
    final insuranceCompanyName = prefs.getString('insuranceCompanyName') ?? '';
    final policyNumber = prefs.getString('policyNumber') ?? '';
    final thirdPartyInsurance = prefs.getString('thirdPartyInsurance') ?? '';
    final fullInsurance = prefs.getString('fullInsurance') ?? '';
    final carId = prefs.getString('carId') ?? '';

    final personalInfoMessage = 'Full Name: $fullName\n'
        'Address: $address\n'
        'ID Number: $idNumber\n'
        'Driver License Number: $driverLicenseNumber\n'
        'Insurance Company Name: $insuranceCompanyName\n'
        'Policy Number: $policyNumber\n'
        'Third Party Insurance: $thirdPartyInsurance\n'
        'Full Insurance: $fullInsurance\n'
        'Car ID: $carId';
    sendMessage(personalInfoMessage);
  }

  Future<void> _fetchMessages() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.100:8000/ws/messages/${widget.carId}'),
      headers: {
        'Authorization': 'Bearer ${widget.authToken}',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        _messages = List<Map<String, dynamic>>.from(json.decode(response.body));
        _messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
      });
      _scrollToBottom();
    } else {
      print('Failed to load messages');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.carId}'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Implement chat deletion logic if needed
              setState(() {
                _messages.clear();
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSentByMe = message['sender'] == widget.userData.vehicle.carId;
                return Align(
                  alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: isSentByMe ? Colors.green[100] : Colors.blue[100],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSentByMe ? 'Me' : message['sender'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSentByMe ? Colors.green[900] : Colors.blue[900],
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(message['message']),
                        SizedBox(height: 5.0),
                        Text(
                          formatTimestamp(message['timestamp']),
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_controller.text);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    sendPersonalInfo();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
