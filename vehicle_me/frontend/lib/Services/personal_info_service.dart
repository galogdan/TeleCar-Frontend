import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:vehicle_me/Models/personal_info.dart';

class PersonalInfoService {
  final String email;

  PersonalInfoService(this.email);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/personal_info_${email.replaceAll('@', '_').replaceAll('.', '_')}.json');
  }

  Future<PersonalInfo?> readPersonalInfo() async {
    try {
      final file = await _localFile;

      if (await file.exists()) {
        final contents = await file.readAsString();
        return PersonalInfo.fromJson(jsonDecode(contents));
      } else {
        return null;
      }
    } catch (e) {
      print('Error reading personal info: $e');
      return null;
    }
  }

  Future<void> writePersonalInfo(PersonalInfo info) async {
    final file = await _localFile;
    await file.writeAsString(jsonEncode(info.toJson()));
  }
}
