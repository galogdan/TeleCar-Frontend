import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:vehicle_me/Models/Auction.dart';
import 'package:vehicle_me/Models/Vehicle.dart';
import 'package:vehicle_me/Models/User.dart';
import 'package:vehicle_me/Pages/HomePage.dart';
import 'package:vehicle_me/Pages/SignUpScreen.dart';

class Auction {
  final String manufacturer;
  final String model;
  final int year;
  final int kilometers;
  final int price;
  final String description;
  final String contactName;
  final String contactNumber;
  final DateTime endTime;


  Auction({
    required this.manufacturer,
    required this.model,
    required this.year,
    required this.kilometers,
    required this.price,
    required this.description,
    required this.contactName,
    required this.contactNumber,
    required this.endTime

  });

  // Named constructor for creating an empty object
  Auction.empty()
      : manufacturer = '',
        model = '',
        year = 0,
        kilometers = 0,
        price = 0,
        description = '',
        contactName = '',
        contactNumber = '',
        endTime = DateTime.now();


  factory Auction.fromJson(Map<String, dynamic> json) {
    return Auction(
      manufacturer: json['manufacturer'],
      model: json['model'],
      year: json['year'],
      kilometers: json['kilometers'],
      price: json['price'],
      description: json['description'],
      contactName: json['contactName'],
      contactNumber: json['contactNumber'],

      endTime: DateTime.parse(json['endTime']),
    );
  }

  Map<String, dynamic> toJson() => {
    'manufacturer': manufacturer,
    'model': model,
    'year': year,
    'kilometers': kilometers,
    'price': price,
    'description': description,
    'contactName': contactName,
    'contactNumber': contactNumber,
    'endTime': endTime.toIso8601String(),
  };
}
