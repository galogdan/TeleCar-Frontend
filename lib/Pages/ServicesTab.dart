import 'package:flutter/material.dart';
import 'package:vehicle_me/Pages/Services/MoreInfoPage.dart';
import 'package:vehicle_me/Pages/Services/StockInfoPage.dart';
import 'package:vehicle_me/Pages/Services/ParkingPage.dart';
import 'package:vehicle_me/Pages/Services/PersonalInfoPage.dart';
import 'package:vehicle_me/Pages/Services/my_tickets_tab.dart';
import 'package:vehicle_me/Models/User.dart';
import 'package:vehicle_me/Pages/Services/locate_vehicle_services.dart'; // Add this import

class ServicesPage extends StatefulWidget {
  final String authToken;
  final String carId;
  final UserRegistration user;

  ServicesPage({required this.authToken, required this.carId, required this.user});

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {

  void _navigateToMyTicketsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyTicketsPage(authToken: widget.authToken, userEmail: widget.user.email),
      ),
    );
  }

  void _navigateToLocateServicesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocateServicesPage(authToken: widget.authToken),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Services',
          style: TextStyle(
            fontFamily: 'Oswald', // Apply the custom font
            fontSize: 28,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: <Widget>[
                _buildCircleButton(
                  icon: Icons.car_repair,
                  label: 'Locate Vehicle Services',
                  onPressed: _navigateToLocateServicesPage,
                ),
                _buildCircleButton(
                  icon: Icons.receipt,
                  label: 'My Tickets',
                  onPressed: _navigateToMyTicketsPage,
                ),
                _buildCircleButton(
                  icon: Icons.info,
                  label: 'More Info',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MoreInfoPage(
                          authToken: widget.authToken,
                          carId: widget.carId,
                        ),
                      ),
                    );
                  },
                ),
                _buildCircleButton(
                  icon: Icons.show_chart,
                  label: 'Stock Info',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockInfoPage(authToken: widget.authToken),
                      ),
                    );
                  },
                ),
                _buildCircleButton(
                  icon: Icons.local_parking,
                  label: 'Locate Parking',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParkingPage(),
                      ),
                    );
                  },
                ),
                _buildCircleButton(
                  icon: Icons.person,
                  label: 'Personal Info',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalInfoPage(
                          email: widget.user.email,
                          carId: widget.user.vehicle.carId,
                          firstName: widget.user.first_name,
                          lastName: widget.user.last_name,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(20),
          ),
          child: Icon(icon, size: 30),
        ),
        SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }
}
