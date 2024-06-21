import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:vehicle_me/config.dart';

class MyTicketsPage extends StatefulWidget {
  final String authToken;
  final String userEmail;

  MyTicketsPage({required this.authToken, required this.userEmail});

  @override
  _MyTicketsPageState createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  final List<Map<String, dynamic>> _tickets = [];

  final TextEditingController _ticketIdController = TextEditingController();
  final TextEditingController _finePriceController = TextEditingController();
  DateTime? _payUntilDate;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    final response = await http.get(
      Uri.parse('$currentIP/tickets/tickets/${widget.userEmail}'),
      headers: {
        'Authorization': 'Bearer ${widget.authToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _tickets.clear();
        final List<dynamic> tickets = json.decode(response.body);
        for (var ticket in tickets) {
          ticket['pay_until'] = DateTime.parse(ticket['pay_until']); // Parse the date string to DateTime
          _tickets.add(ticket);
        }
      });
    } else {
      // Handle error
      print('Failed to load tickets');
    }
  }

  Future<void> _addTicket() async {
    if (_ticketIdController.text.isNotEmpty &&
        _finePriceController.text.isNotEmpty &&
        _payUntilDate != null) {
      final response = await http.post(
        Uri.parse('$currentIP/tickets/tickets/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.authToken}',
        },
        body: json.encode({
          'ticket_id': _ticketIdController.text,
          'fine_price': double.parse(_finePriceController.text),
          'pay_until': DateFormat('yyyy-MM-dd').format(_payUntilDate!), // Convert DateTime to string
          'user_email': widget.userEmail,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _tickets.add({
            'ticket_id': _ticketIdController.text,
            'fine_price': double.parse(_finePriceController.text),
            'pay_until': _payUntilDate,
          });
          _ticketIdController.clear();
          _finePriceController.clear();
          _payUntilDate = null;
        });
      } else {
        // Handle error
        print('Failed to add ticket');
      }
    }
  }

  Future<void> _deleteTicket(String ticketId) async {
    final response = await http.delete(
      Uri.parse('$currentIP/tickets/tickets/$ticketId'),
      headers: {
        'Authorization': 'Bearer ${widget.authToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _tickets.removeWhere((ticket) => ticket['ticket_id'] == ticketId);
      });
    } else {
      // Handle error
      print('Failed to delete ticket');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _payUntilDate) {
      setState(() {
        _payUntilDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tickets'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _ticketIdController,
              decoration: InputDecoration(labelText: 'Ticket ID'),
            ),
            TextField(
              controller: _finePriceController,
              decoration: InputDecoration(labelText: 'Fine Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(_payUntilDate == null
                    ? 'No date chosen!'
                    : 'Pay Until: ${DateFormat('yyyy-MM-dd').format(_payUntilDate!)}'),
                Spacer(),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Choose Date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTicket,
              child: Text('Add Ticket'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tickets.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text('Ticket ID: ${_tickets[index]['ticket_id']}'),
                      subtitle: Text(
                          'Fine: \$${_tickets[index]['fine_price']}, Pay Until: ${DateFormat('yyyy-MM-dd').format(_tickets[index]['pay_until'])}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteTicket(_tickets[index]['ticket_id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
