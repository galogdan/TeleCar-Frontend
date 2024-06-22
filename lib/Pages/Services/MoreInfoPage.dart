import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vehicle_me/Services/Loading.dart';
import 'package:vehicle_me/config.dart';

class MoreInfoPage extends StatefulWidget {
  final String authToken;
  final String carId;

  MoreInfoPage({required this.authToken, required this.carId});

  @override
  _MoreInfoPageState createState() => _MoreInfoPageState();
}

class _MoreInfoPageState extends State<MoreInfoPage> {
  late Future<Map<String, dynamic>> _vehicleInfo;

  @override
  void initState() {
    super.initState();
    _vehicleInfo = fetchVehicleInfo();
  }

  Future<Map<String, dynamic>> fetchVehicleInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$currentIP/services/vehicle_info/${widget.carId}'),
        headers: {
          'Authorization': 'Bearer ${widget.authToken}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to load vehicle info: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load vehicle info');
      }
    } catch (error) {
      print('Error fetching vehicle info: $error');
      throw Exception('Failed to load vehicle info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'More Info',
          style: TextStyle(
            fontFamily: 'Oswald', // Apply the custom font
            fontSize: 28,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _vehicleInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CustomLoadingIndicator());
          } else if (snapshot.hasError) {
            print('Snapshot error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('No vehicle info available');
            return Center(child: Text('No vehicle info available'));
          } else {
            var vehicleInfo = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    icon: Icons.event_available,
                    title: 'Last Vehicle Test',
                    value: vehicleInfo['last_test_date'] ?? 'N/A',
                  ),
                  _buildInfoCard(
                    icon: Icons.event_busy,
                    title: 'Test Expiration',
                    value: vehicleInfo['test_expiration_date'] ?? 'N/A',
                  ),
                  _buildInfoCard(
                    icon: Icons.directions_car,
                    title: 'On The Road Since',
                    value: vehicleInfo['on_road_date'] ?? 'N/A',
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.deepPurple),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
