import 'dart:convert';
import 'package:flutter/services.dart';

class DataLoader {
  static Future<List<dynamic>> loadJsonData(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      print('Error loading data from $assetPath: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> loadJsonDataAsMap(String assetPath) async {
    try {
      final String jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      print('Error loading data from $assetPath: $e');
      return null;
    }
  }
}
