import 'package:flutter/material.dart';
import 'Vehicle.dart';

class UserRegistration {
  final String email;
  final String first_name;
  final String last_name;
  final String password;
  final Vehicle vehicle;
  final bool gender;

  UserRegistration({
    required this.email,
    required this.first_name,
    required this.last_name,
    required this.password,
    required this.vehicle,
    required this.gender,
  });

  // Named constructor for creating an empty object
  UserRegistration.empty()
      : email = '',
        first_name = '',
        last_name = '',
        password = '',
        vehicle = Vehicle(carId: ''),
        gender = true;

  factory UserRegistration.fromJson(Map<String, dynamic> json) {
  return UserRegistration(
  email: json['email'],
  first_name: json['first_name'],
  last_name: json['last_name'],
  password: json['password'],
  vehicle: Vehicle.fromJson(json['vehicle']),
  gender: json['gender'],
  );
  }



  Map<String, dynamic> toJson() => {
    'email': email,
    'first_name': first_name,
    'last_name': last_name,
    'password': password,
    'vehicle': vehicle.toJson(),
    'gender': gender,
  };
}

