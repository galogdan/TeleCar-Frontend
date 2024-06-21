import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehicle_me/config.dart';

class ParkingPage extends StatefulWidget {
  @override
  _ParkingPageState createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  late GoogleMapController _mapController;
  LatLng _initialPosition = LatLng(0, 0);
  bool _locationFetched = false;
  List<Marker> _markers = [];
  List<Map<String, dynamic>> _parkingLocations = [];

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
        _fetchParkingLocations();
        print('Current Location: $_initialPosition');
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _fetchParkingLocations() async {
    print('Fetching parking locations for: $_initialPosition');
    try {
      final response = await http.get(
          Uri.parse('$currentIP/maps/parking-locations/?lat=${_initialPosition.latitude}&lon=${_initialPosition.longitude}')
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        setState(() {
          _parkingLocations = results.map<Map<String, dynamic>>((parking) => {
            'placeId': parking['place_id'],
            'address': parking['address'] ?? 'No address available',
            'lat': parking['geometry']['location']['lat'],
            'lon': parking['geometry']['location']['lng']
          }).toList();
          _markers = _parkingLocations.map<Marker>((parking) {
            return Marker(
              markerId: MarkerId(parking['placeId']),
              position: LatLng(parking['lat'], parking['lon']),
              infoWindow: InfoWindow(
                title: parking['address'],
                snippet: parking['address'],
                onTap: () => _launchMaps(parking['lat'], parking['lon']),
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            );
          }).toList();
          print('Parking markers: $_markers');
        });
      } else {
        print('Failed to load parking locations: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching parking locations: $e');
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

  void _onParkingSelected(Map<String, dynamic> parking) {
    _mapController.animateCamera(CameraUpdate.newLatLng(LatLng(parking['lat'], parking['lon'])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locate Parking'),
      ),
      body: _locationFetched
          ? Column(
        children: [
          Expanded(
            flex: 3,
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 15.0,
              ),
              markers: Set.from(_markers),
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: _parkingLocations.length,
              itemBuilder: (context, index) {
                final parking = _parkingLocations[index];
                return ListTile(
                  title: Text(parking['address']),
                  onTap: () => _onParkingSelected(parking),
                  trailing: IconButton(
                    icon: Icon(Icons.directions),
                    onPressed: () => _launchMaps(parking['lat'], parking['lon']),
                  ),
                );
              },
            ),
          ),
        ],
      )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: _locationFetched
          ? FloatingActionButton(
        onPressed: _fetchParkingLocations,
        child: Icon(Icons.refresh),
      )
          : null,
    );
  }
}
