import 'package:flutter/material.dart';
import 'package:vehicle_me/Models/personal_info.dart';
import 'package:vehicle_me/Services/personal_info_service.dart';

class PersonalInfoPage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String carId;
  final String email;

  PersonalInfoPage({
    required this.firstName,
    required this.lastName,
    required this.carId,
    required this.email,
  });

  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late final PersonalInfoService _service;
  PersonalInfo? _personalInfo;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _driverLicenseNumberController = TextEditingController();
  final _insuranceCompanyNameController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _thirdPartyInsuranceController = TextEditingController();
  final _fullInsuranceController = TextEditingController();
  final _carIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _service = PersonalInfoService(widget.email);
    _fullNameController.text = '${widget.firstName} ${widget.lastName}';
    _carIdController.text = widget.carId;
    _loadPersonalInfo();
  }

  Future<void> _loadPersonalInfo() async {
    final info = await _service.readPersonalInfo();
    setState(() {
      _personalInfo = info;
      if (info != null) {
        _addressController.text = info.address ?? '';
        _idNumberController.text = info.idNumber ?? '';
        _driverLicenseNumberController.text = info.driverLicenseNumber ?? '';
        _insuranceCompanyNameController.text = info.insuranceCompanyName ?? '';
        _policyNumberController.text = info.policyNumber ?? '';
        _thirdPartyInsuranceController.text = info.thirdPartyInsurance ?? '';
        _fullInsuranceController.text = info.fullInsurance ?? '';
      }
    });
  }

  Future<void> _savePersonalInfo() async {
    if (_formKey.currentState!.validate()) {
      final info = PersonalInfo(
        fullName: _fullNameController.text,
        address: _addressController.text,
        idNumber: _idNumberController.text,
        driverLicenseNumber: _driverLicenseNumberController.text,
        insuranceCompanyName: _insuranceCompanyNameController.text,
        policyNumber: _policyNumberController.text,
        thirdPartyInsurance: _thirdPartyInsuranceController.text.isNotEmpty
            ? _thirdPartyInsuranceController.text
            : null,
        fullInsurance: _fullInsuranceController.text.isNotEmpty
            ? _fullInsuranceController.text
            : null,
        carId: _carIdController.text,
      );
      await _service.writePersonalInfo(info);
      setState(() {
        _personalInfo = info;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          'Personal Info',
          style: TextStyle(
            fontFamily: 'Oswald', // Apply the custom font
            fontSize: 28,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _personalInfo == null
            ? Center(child: Text('Please fill your info'))
            : _buildPersonalInfoForm(),
      ),
      floatingActionButton: _personalInfo == null
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _personalInfo = PersonalInfo(
              fullName: '',
              address: '',
              idNumber: '',
              driverLicenseNumber: '',
              insuranceCompanyName: '',
              policyNumber: '',
              thirdPartyInsurance: null,
              fullInsurance: null,
              carId: widget.carId,
            );
          });
        },
        child: Icon(Icons.edit),
      )
          : null,
    );
  }

  Widget _buildPersonalInfoForm() {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(labelText: 'Full Name'),
            readOnly: true,
            style: TextStyle(color: Colors.grey),
          ),
          TextFormField(
            controller: _carIdController,
            decoration: InputDecoration(labelText: 'Car ID'),
            readOnly: true,
            style: TextStyle(color: Colors.grey),
          ),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(labelText: 'Address'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _idNumberController,
            decoration: InputDecoration(labelText: 'ID Number'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your ID number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _driverLicenseNumberController,
            decoration: InputDecoration(labelText: 'Driver License Number'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your driver license number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _insuranceCompanyNameController,
            decoration: InputDecoration(labelText: 'Insurance Company Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your insurance company name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _policyNumberController,
            decoration: InputDecoration(labelText: 'Policy Number'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your policy number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _thirdPartyInsuranceController,
            decoration: InputDecoration(labelText: 'Third Party Insurance (if available)'),
          ),
          TextFormField(
            controller: _fullInsuranceController,
            decoration: InputDecoration(labelText: 'Full Insurance (if available)'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _savePersonalInfo,
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
