import 'dart:convert';
import '../api_client.dart';
import '../constants.dart';

class UserService {
  /// Get current user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await ApiClient.get(ApiConstants.userProfile);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        var message = 'Failed to load profile';
        try {
          final err = jsonDecode(response.body);
          if (err['message'] != null) message = err['message'];
        } catch (_) {}
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Update current user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? bio,
    String? phoneNumber,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['fullName'] = fullName;
      if (bio != null) body['bio'] = bio;
      if (phoneNumber != null) body['phoneNumber'] = phoneNumber;

      final response = await ApiClient.put(ApiConstants.userProfile, body);

      if (response.statusCode == 200 || response.statusCode == 204) {
        dynamic data;
        if (response.body.isNotEmpty) {
          try {
            data = jsonDecode(response.body);
          } catch (_) {}
        }
        return {'success': true, 'data': data};
      } else {
        var message = 'Failed to update profile';
        try {
          final err = jsonDecode(response.body);
          if (err['message'] != null) message = err['message'];
        } catch (_) {}
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Change password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await ApiClient.post(
        ApiConstants.changePassword,
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'Password changed successfully'};
      } else {
        var message = 'Failed to change password';
        try {
          final err = jsonDecode(response.body);
          if (err['message'] != null) {
            message = err['message'];
          } else if (err['title'] != null) {
            message = err['title'];
          }
        } catch (_) {}
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
