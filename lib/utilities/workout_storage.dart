import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class WorkoutStorage {
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
    return file.writeAsString(
        jsonEncode(data.map((key, value) => MapEntry(key.toString(), value))));
  }

  static Future<File> saveWorkout2(Map data) async {
    final file = await _localFile2;

    // Write the file
    return file.writeAsString(
        jsonEncode(data.map((key, value) => MapEntry(key.toString(), value))));
  }

  /*static Future<Map?> loadWorkout() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return jsonDecode(contents);
    } catch (e) {
      // If encountering an error, return 0
      return null;
    }
  }*/

  static Future<Map<DateTime, int>?> loadWorkout() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      Map temp = jsonDecode(contents);
      return temp.map((key, value) => MapEntry(DateTime.parse(key), value));
    } catch (e) {
      // If encountering an error, return 0
      return null;
    }
  }

  static Future<Map<DateTime, int>?> loadWorkout2() async {
    try {
      final file = await _localFile2;

      // Read the file
      final contents = await file.readAsString();

      Map temp = jsonDecode(contents);
      return temp.map((key, value) => MapEntry(DateTime.parse(key), value));
    } catch (e) {
      // If encountering an error, return 0
      return null;
    }
  }
}
