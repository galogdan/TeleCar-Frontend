import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehicle_me/config.dart';
import 'package:vehicle_me/Services/Loading.dart';

class LocateServicesPage extends StatefulWidget {
  final String authToken;

  LocateServicesPage({required this.authToken});

  @override
  _LocateServicesPageState createState() => _LocateServicesPageState();
}

class _LocateServicesPageState extends State<LocateServicesPage> {
  late GoogleMapController _mapController;
  LatLng _initialPosition = LatLng(0, 0);
  bool _locationFetched = false;
  List<Marker> _markers = [];
  List<Map<String, dynamic>> _serviceLocations = [];
  String _selectedServiceType = 'Car Garages';
  final List<String> _serviceOptions = ['Car Garages', 'Gas Stations', 'Car Washes'];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _locationFetched = true;
        _fetchServiceLocations();
        print('Current Location: $_initialPosition');
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _fetchServiceLocations() async {
    print('Fetching service locations for: $_initialPosition');
    try {
      final response = await http.get(
          Uri.parse('$currentIP/maps/service-locations/?lat=${_initialPosition.latitude}&lon=${_initialPosition.longitude}&type=$_selectedServiceType')
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        setState(() {
          _serviceLocations = results.map<Map<String, dynamic>>((service) => {
            'placeId': service['place_id'],
            'address': service['address'] ?? 'No address available',
            'rating': service['rating']?.toString() ?? 'No rating',
            'lat': service['geometry']['location']['lat'],
            'lon': service['geometry']['location']['lng']
          }).toList();
          _markers = _serviceLocations.map<Marker>((service) {
            return Marker(
              markerId: MarkerId(service['placeId']),
              position: LatLng(service['lat'], service['lon']),
              infoWindow: InfoWindow(
                title: service['address'],
                snippet: 'Rating: ${service['rating']}',
                onTap: () => _launchMaps(service['lat'], service['lon']),
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            );
          }).toList();
          print('Service markers: $_markers');
        });
      } else {
        print('Failed to load service locations: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching service locations: $e');
    }
  }

  Future<void> _launchMaps(double lat, double lon) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _onServiceSelected(Map<String, dynamic> service) {
    _mapController.animateCamera(CameraUpdate.newLatLng(LatLng(service['lat'], service['lon'])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Locate Services',
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
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedServiceType,
              items: _serviceOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedServiceType = newValue!;
                  _fetchServiceLocations();
                });
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: _locationFetched
                ? GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 15.0,
              ),
              markers: Set.from(_markers),
            )
                : Center(child: CustomLoadingIndicator()),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: _serviceLocations.length,
              itemBuilder: (context, index) {
                final service = _serviceLocations[index];
                return ListTile(
                  title: Text(service['address']),
                  subtitle: Text('Rating: ${service['rating']}'),
                  onTap: () => _onServiceSelected(service),
                  trailing: IconButton(
                    icon: Icon(Icons.directions),
                    onPressed: () => _launchMaps(service['lat'], service['lon']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _locationFetched
          ? FloatingActionButton(
        onPressed: _fetchServiceLocations,
        child: Icon(Icons.refresh),
      )
          : null,
    );
  }
}
