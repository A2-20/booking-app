import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LocalStorageManager {
  static const String _currentUserKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  // Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove('user_profile');
  }

  // Current User
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  static Future<void> setCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, userId);
  }

  static Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Full User Object
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('user_profile');
    if (userJson == null) return null;
    return UserModel.fromJson(json.decode(userJson));
  }

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', json.encode(user.toJson()));
  }

  static const String _roomsKey = 'rooms_data';

  // Rooms
  static Future<List<Map<String, dynamic>>> getRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? roomsJson = prefs.getString(_roomsKey);
    if (roomsJson == null) return [];
    final List<dynamic> decoded = json.decode(roomsJson);
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> saveRooms(List<Map<String, dynamic>> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roomsKey, json.encode(rooms));
  }

  static const String _paymentsKey = 'payments_data';

  // Payments
  static Future<List<Map<String, dynamic>>> getPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? paymentsJson = prefs.getString(_paymentsKey);
    if (paymentsJson == null) return [];
    final List<dynamic> decoded = json.decode(paymentsJson);
    return decoded.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<void> savePayments(List<Map<String, dynamic>> payments) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paymentsKey, json.encode(payments));
  }

  // Initialize data (No longer needed for local assets)
  static Future<void> initializeData() async {
    // API logic replaces this
  }
}
