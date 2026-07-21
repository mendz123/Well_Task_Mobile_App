import 'package:flutter/foundation.dart';

class ApiConstants {
  // Automatically select the correct base URL based on platform:
  // - Web / Desktop / iOS Simulator: http://localhost:5018/api
  // - Android Emulator: http://10.0.2.2:5018/api
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5018/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5018/api';
    } else {
      return 'http://localhost:5018/api';
    }
  }

  // Auth Endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';

  // Project Endpoints
  static String get projects => '$baseUrl/projects';
  static String projectDetail(int id) => '$baseUrl/projects/$id';
  static String inviteMember(int id) => '$baseUrl/projects/$id/invite';
  static String leaveProject(int id) => '$baseUrl/projects/$id/leave';
  
  // Leave request handling (Guid based)
  static String approveLeaveRequest(String requestId) => '$baseUrl/projects/leave-requests/$requestId/approve';
  static String rejectLeaveRequest(String requestId) => '$baseUrl/projects/leave-requests/$requestId/reject';

  // User Profile Endpoints
  static String get userProfile => '$baseUrl/users/me';
  static String get changePassword => '$baseUrl/users/me/change-password';
  static String get uploadAvatar => '$baseUrl/users/me/avatar';
}
