import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class Storage {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/pushUpSaves.json');
  }

  static Future<File> get _localFile2 async {
    final path = await _localPath;
    return File('$path/pullUpSaves.json');
  }

  static Future<File> saveWorkout(Map data) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(json.encode(data));
  }

  static Future<File> saveWorkout2(Map data) async {
    final file = await _localFile2;

    // Write the file
    return file.writeAsString(json.encode(data));
  }

  static Future<Map?> loadWorkout() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return json.decode(contents);
    } catch (e) {
      // If encountering an error, return 0
      return null;
    }
  }

  static Future<Map?> loadWorkout2() async {
    try {
      final file = await _localFile2;

      // Read the file
      final contents = await file.readAsString();

      return json.decode(contents);
    } catch (e) {
      // If encountering an error, return 0
      return null;
    }
  }
}
