import 'dart:convert';

class PersonalInfo {
  String fullName;
  String address;
  String idNumber;
  String driverLicenseNumber;
  String insuranceCompanyName;
  String policyNumber;
  String? thirdPartyInsurance;
  String? fullInsurance;
  String carId;

  PersonalInfo({
    required this.fullName,
    required this.address,
    required this.idNumber,
    required this.driverLicenseNumber,
    required this.insuranceCompanyName,
    required this.policyNumber,
    this.thirdPartyInsurance,
    this.fullInsurance,
    required this.carId,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      fullName: json['fullName'] ?? '',
      address: json['address'] ?? '',
      idNumber: json['idNumber'] ?? '',
      driverLicenseNumber: json['driverLicenseNumber'] ?? '',
      insuranceCompanyName: json['insuranceCompanyName'] ?? '',
      policyNumber: json['policyNumber'] ?? '',
      thirdPartyInsurance: json['thirdPartyInsurance'],
      fullInsurance: json['fullInsurance'],
      carId: json['carId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'address': address,
      'idNumber': idNumber,
      'driverLicenseNumber': driverLicenseNumber,
      'insuranceCompanyName': insuranceCompanyName,
      'policyNumber': policyNumber,
      'thirdPartyInsurance': thirdPartyInsurance,
      'fullInsurance': fullInsurance,
      'carId': carId,
    };
  }
}
