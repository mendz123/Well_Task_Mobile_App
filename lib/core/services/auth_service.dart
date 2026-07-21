import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
class AuthService {
  static const String keyAccessToken = 'AccessToken';
  static const String keyUserEmail = 'UserEmail';
  static const String keyUserId = 'UserId';
  static const String keyUserName = 'UserName';
  /// Get stored userId
  static Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyUserId) ?? 0;
  }
  /// Get stored display name
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserName) ?? 'User';
  }
  /// Register a new user
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final err = jsonDecode(response.body);
        return {'success': false, 'message': err['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  /// Login a user and save tokens
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        if (data['accessToken'] != null) {
          await prefs.setString(keyAccessToken, data['accessToken']);
          await prefs.setString(keyUserEmail, email);
          // Save userId and name from login response
          if (data['userId'] != null) {
            await prefs.setInt(keyUserId, (data['userId'] as num).toInt());
          }
          if (data['fullName'] != null) {
            await prefs.setString(keyUserName, data['fullName'].toString());
          } else {
            await prefs.setString(keyUserName, email.split('@').first);
          }
          return {'success': true, 'data': data};
        } else {
          return {'success': false, 'message': 'Token missing in response'};
        }
      } else {
        var message = 'Login failed';
        try {
          final err = jsonDecode(response.body);
          if (err['message'] != null) {
            message = err['message'];
          }
        } catch (_) {}
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  /// Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyAccessToken);
    await prefs.remove(keyUserEmail);
    await prefs.remove(keyUserId);
    await prefs.remove(keyUserName);
  }
  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(keyAccessToken);
  }
}