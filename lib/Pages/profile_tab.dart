import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:vehicle_me/Models/Auction.dart';
import 'package:vehicle_me/Models/User.dart';
import 'market_tab.dart';
import 'chat_tab.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart'; 

class ProfileTab extends StatelessWidget {
  final String authToken;
  UserRegistration user;

  ProfileTab({required this.authToken, required this.user});




  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    this.user = UserRegistration.empty();
  }

  @override
  Widget build(BuildContext context) {
    String gender = user.gender ? "Male" : "Female";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'User Profile',
          style: TextStyle(
            fontFamily: 'Oswald', // Apply the custom font
            fontSize: 28,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.deepPurple.shade100,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          surfaceTintColor: Colors.deepPurple,
          color: Colors.deepPurple.shade50,
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First Name: ${user.first_name}',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold , fontFamily: 'Oswald',letterSpacing: 1 ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Last Name: ${user.last_name}',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: 'Oswald',letterSpacing: 1),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Email: ${user.email}',
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Oswald',letterSpacing: 1),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Car ID: ${user.vehicle.carId}',
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Oswald',letterSpacing: 1),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Color: ${user.vehicle.color}',
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Oswald',letterSpacing: 1),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Brand: ${user.vehicle.brend}',
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Oswald',letterSpacing: 1),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Model: ${user.vehicle.model}',
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Oswald',letterSpacing: 1, ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Year: ${user.vehicle.year}',
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Oswald',letterSpacing: 1),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Gender: $gender',
                  style: TextStyle(fontSize: 20.0, fontFamily: 'Oswald',letterSpacing: 1),
                ),

              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _logout(context),
        child: Icon(Icons.logout),
        tooltip: 'Logout',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
