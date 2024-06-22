import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vehicle_me/Services/Loading.dart';
import 'package:vehicle_me/config.dart';

class StockInfoPage extends StatefulWidget {
  final String authToken;

  StockInfoPage({required this.authToken});

  @override
  _StockInfoPageState createState() => _StockInfoPageState();
}

class _StockInfoPageState extends State<StockInfoPage> {
  late Future<List<Map<String, dynamic>>> _stockInfo;

  @override
  void initState() {
    super.initState();
    _stockInfo = fetchStockInfo();
  }

  Future<List<Map<String, dynamic>>> fetchStockInfo() async {
    final response = await http.get(
      Uri.parse('$currentIP/services/stock_info'),
      headers: {
        'Authorization': 'Bearer ${widget.authToken}',
      },
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      print("Stock Info Response: $data"); // Log the response data
      return List<Map<String, dynamic>>.from(data);
    } else {
      print("Failed to load stock info: ${response.statusCode} ${response.body}");
      throw Exception('Failed to load stock info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Info'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _stockInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CustomLoadingIndicator());
          } else if (snapshot.hasError) {
            print("Error in FutureBuilder: ${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No stock info available'));
          } else {
            var stockInfo = snapshot.data!;
            return ListView.builder(
              itemCount: stockInfo.length,
              itemBuilder: (context, index) {
                var stock = stockInfo[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: Icon(Icons.business, size: 40, color: Colors.blue),
                    title: Text(stock['name'] ?? 'N/A', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Symbol: ${stock['symbol'] ?? 'N/A'}'),
                        Text('Price: \$${(stock['price'] ?? 0.0).toStringAsFixed(2)}'),
                        Text('Change: ${stock['change']?.toStringAsFixed(2) ?? 'N/A'}'),
                        Text('Percent Change: ${stock['percent_change']?.toStringAsFixed(2) ?? 'N/A'}%'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
