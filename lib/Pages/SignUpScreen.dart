import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vehicle_me/Models/User.dart';
import 'package:vehicle_me/Models/Vehicle.dart';
import 'package:vehicle_me/config.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  final TextEditingController _carIdController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isMale = true;

  Future<void> _signup() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String repeatPassword = _repeatPasswordController.text;
    final String carId = _carIdController.text;
    final String firstName = _firstNameController.text;
    final String lastName = _lastNameController.text;
    final bool gender = _isMale;

    if (email.isEmpty ||
        password.isEmpty ||
        repeatPassword.isEmpty ||
        carId.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty) {
      print('Please fill in all fields');
      return;
    }

    if (password != repeatPassword) {
      print('Passwords do not match');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$currentIP/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
          "vehicle": Vehicle(carId: carId),
          "gender": gender,
          "first_name": firstName,
          "last_name": lastName,
        }),
      );

      if (response.statusCode == 200) {
        print('Signup successful');
        // Handle successful signup (e.g., navigate to login screen)
        Navigator.pop(context); // Navigate back to login screen
      } else {
        print('Signup failed: ${response.body}');
        // Handle failed signup (display error message to user)
      }
    } catch (e) {
      print('Error signing up: $e');
      // Handle connection or server error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _repeatPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Repeat Password',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _carIdController,
                decoration: InputDecoration(
                  labelText: 'Car ID',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text('Gender:'),
                  SizedBox(width: 8.0),
                  DropdownButton<bool>(
                    value: _isMale,
                    onChanged: (value) {
                      setState(() {
                        _isMale = value!;
                      });
                    },
                    items: [
                      DropdownMenuItem<bool>(
                        value: true,
                        child: Text('Male'),
                      ),
                      DropdownMenuItem<bool>(
                        value: false,
                        child: Text('Female'),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _signup,
                child: Text('Signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
