import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class AuthService {
  static const String keyAccessToken = 'AccessToken';
  static const String keyUserEmail = 'UserEmail';

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
        dynamic responseData;
        if (response.body.isNotEmpty) {
          try {
            responseData = jsonDecode(response.body);
          } catch (_) {
            responseData = response.body;
          }
        }
        return {'success': true, 'data': responseData};
      } else {
        var message = 'Registration failed';
        try {
          final err = jsonDecode(response.body);
          if (err['message'] != null) {
            message = err['message'];
          } else if (err['title'] != null) {
            message = err['title'];
          }
        } catch (_) {
          if (response.body.isNotEmpty) message = response.body;
        }
        return {'success': false, 'message': message};
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
        final token = data['accessToken'] ?? data['token'];

        final prefs = await SharedPreferences.getInstance();
        if (token != null) {
          await prefs.setString(keyAccessToken, token);
          await prefs.setString(keyUserEmail, email);
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
          } else if (err['title'] != null) {
            message = err['title'];
          }
        } catch (_) {
          if (response.body.isNotEmpty) message = response.body;
        }
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
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(keyAccessToken);
  }
}
