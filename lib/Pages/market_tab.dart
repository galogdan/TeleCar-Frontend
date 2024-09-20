import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show FilteringTextInputFormatter, rootBundle;
import 'package:vehicle_me/Models/Auction.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:vehicle_me/config.dart';
import 'package:vehicle_me/Services/Loading.dart';

int selectedYear = 1970; //
String selectedManufacturer = ''; //
String selectedModel = ''; //
String selectedPrefix = '050'; //

Map<String, List<String>> carModels = {};

class MarketTab extends StatefulWidget {
  @override
  _MarketTabState createState() => _MarketTabState();
}

class _MarketTabState extends State<MarketTab> {
  final List<Auction> _auctions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCarData();
    _fetchAuctionsFromDatabase();
  }

  Future<void> _loadCarData() async {
    try {
      final String response = await rootBundle.loadString('assets/vehicles.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        carModels = {for (var item in data) item['brand']: List<String>.from(item['models'])};
        if (carModels.isNotEmpty) {
          selectedManufacturer = carModels.keys.first;
          selectedModel = carModels[selectedManufacturer]?.first ?? '';
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchAuctionsFromDatabase() async {
    try {
      final response = await http.get(Uri.parse('$currentIP/auctions/get_auctions'));
      if (response.statusCode == 200) {
        final List<dynamic> auctionData = json.decode(response.body);
        setState(() {
          _auctions.clear();
          for (var auction in auctionData) {
            _auctions.add(Auction.fromJson(auction));
          }
        });
      } else {
        _handleError('Failed to load auctions: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('Failed to load auctions: $e');
    }
  }

  Future<void> _addAuctionToDatabase(Auction auction) async {
    final response = await http.post(
      Uri.parse('$currentIP/auctions/addNewAuction'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(auction.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        _auctions.add(auction);
      });
      Navigator.of(context).pop(); // סגור את הדיאלוג
      print('Auction added successfully');
    } else {
      print('Failed to add auction: ${response.body}');
      _handleError('Failed to add auction. Please try again.');
    }
  }

  Future<void> _showAddAuctionDialog() async {
    TextEditingController carKMController = TextEditingController();
    TextEditingController carPriceController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController contactNameController = TextEditingController();
    TextEditingController contactNumberSuffixController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Enter Details'),
            content: SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading) ...[
                      Center(child: CustomLoadingIndicator())
                    ] else ...[
                      _buildRowWithTitle('Manufacturer:', DropdownButton<String>(
                        value: selectedManufacturer.isEmpty ? null : selectedManufacturer,
                        onChanged: (value) {
                          setState(() {
                            selectedManufacturer = value ?? selectedManufacturer;
                            selectedModel = carModels[selectedManufacturer]?.first ?? '';
                          });
                        },
                        items: carModels.keys.map((manufacturer) {
                          return DropdownMenuItem<String>(
                            value: manufacturer,
                            child: Text(manufacturer),
                          );
                        }).toList(),
                      )),
                      _buildRowWithTitle('Model:', DropdownButton<String>(
                        value: selectedModel.isEmpty ? null : selectedModel,
                        onChanged: (value) {
                          setState(() {
                            selectedModel = value ?? selectedModel;
                          });
                        },
                        items: carModels[selectedManufacturer]?.map((model) {
                          return DropdownMenuItem<String>(
                            value: model,
                            child: Text(model),
                          );
                        }).toList() ?? [],
                      )),
                      _buildRowWithTitle('Year:', DropdownButton<int>(
                        value: selectedYear,
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value ?? selectedYear;
                          });
                        },
                        items: List.generate(2025 - 1970, (index) {
                          return DropdownMenuItem<int>(
                            value: 1970 + index,
                            child: Text((1970 + index).toString()),
                          );
                        }),
                      )),
                      _buildRowWithTitle('Kilometers:', TextField(
                        controller: carKMController,
                        decoration: InputDecoration(
                          hintText: 'Enter kilometers',
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      )),
                      _buildRowWithTitle('Price:', TextField(
                        controller: carPriceController,
                        decoration: InputDecoration(
                          hintText: 'Enter price',
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      )),
                      _buildRowWithTitle('Description:', TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter description',
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        maxLength: 100,
                      )),
                      _buildRowWithTitle('Contact Name:', TextField(
                        controller: contactNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter contact name',
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      )),
                      _buildRowWithTitle('Contact Number:', Row(
                        children: [
                          DropdownButton<String>(
                            value: selectedPrefix,
                            onChanged: (value) {
                              setState(() {
                                selectedPrefix = value ?? selectedPrefix;
                              });
                            },
                            items: ['050', '052', '053', '054'].map((prefix) {
                              return DropdownMenuItem<String>(
                                value: prefix,
                                child: Text(prefix),
                              );
                            }).toList(),
                          ),
                          Flexible(
                            child: TextField(
                              controller: contactNumberSuffixController,
                              decoration: InputDecoration(
                                hintText: 'Enter number',
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                                counterText: '',
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 7,
                            ),
                          ),
                        ],
                      )),
                    ]
                  ],
                ),
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Validate and add the auction
                      if (descriptionController.text.isNotEmpty &&
                          carKMController.text.isNotEmpty &&
                          carPriceController.text.isNotEmpty &&
                          contactNameController.text.isNotEmpty &&
                          contactNumberSuffixController.text.isNotEmpty) {
                        DateTime endTime = DateTime.now().add(Duration(days: 7));
                        Auction newAuction = Auction(
                          manufacturer: selectedManufacturer,
                          model: selectedModel,
                          year: selectedYear,
                          kilometers: int.parse(carKMController.text),
                          price: int.parse(carPriceController.text),
                          description: descriptionController.text,
                          contactName: contactNameController.text,
                          contactNumber: '$selectedPrefix${contactNumberSuffixController.text}',
                          endTime: endTime,
                        );

                        _addAuctionToDatabase(newAuction);
                      } else {
                        _handleError('Please fill in all fields.');
                      }
                    },
                    child: Text('Add'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRowWithTitle(String title, Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(title),
          ),
          Expanded(
            flex: 3,
            child: widget,
          ),
        ],
      ),
    );
  }

  void _handleError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAuctionDescriptionDialog(Auction auction) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Auction Description'),
        content: Text(auction.description),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Market',
          style: TextStyle(
            fontFamily: 'Oswald', // Apply the custom font
            fontSize: 28,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.deepPurple.shade100,
      resizeToAvoidBottomInset: false,
      body: isLoading
          ? Center(child: CustomLoadingIndicator()) //
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _showAddAuctionDialog,
                child: Text('Add new post'),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _auctions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Car Model: ${_auctions[index].model}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Manufacturer: ${_auctions[index].manufacturer}'),
                      Text('Year: ${_auctions[index].year}'),
                      Text('Price: ${_auctions[index].price}'),
                      Text('Contact Name: ${_auctions[index].contactName}'),
                      Text('Contact Number: ${_auctions[index].contactNumber}'),
                      Text('End Time: ${DateFormat('yyyy-MM-dd HH:mm').format(_auctions[index].endTime)}'),
                    ],
                  ),
                  onTap: () {
                    _showAuctionDescriptionDialog(_auctions[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
