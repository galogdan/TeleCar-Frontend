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
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create an Account',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 32.0),
              _buildTextField(_emailController, 'Email'),
              SizedBox(height: 16.0),
              _buildTextField(_passwordController, 'Password', obscureText: true),
              SizedBox(height: 16.0),
              _buildTextField(_repeatPasswordController, 'Repeat Password', obscureText: true),
              SizedBox(height: 16.0),
              _buildTextField(_carIdController, 'Car ID'),
              SizedBox(height: 16.0),
              _buildTextField(_firstNameController, 'First Name'),
              SizedBox(height: 16.0),
              _buildTextField(_lastNameController, 'Last Name'),
              SizedBox(height: 16.0),
              _buildGenderDropdown(),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'Signup',
                  style: TextStyle(fontSize: 18.0, color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Gender:',
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
        SizedBox(width: 8.0),
        DropdownButton<bool>(
          value: _isMale,
          dropdownColor: Colors.deepPurple,
          onChanged: (value) {
            setState(() {
              _isMale = value!;
            });
          },
          items: [
            DropdownMenuItem<bool>(
              value: true,
              child: Text('Male', style: TextStyle(color: Colors.white)),
            ),
            DropdownMenuItem<bool>(
              value: false,
              child: Text('Female', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}
