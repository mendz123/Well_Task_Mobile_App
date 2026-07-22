import 'package:flutter/foundation.dart';

class ApiConstants {
  // Automatically select the correct base URL based on platform:
  // - Web / Desktop / iOS Simulator: http://localhost:5018/api
  // - Android Emulator: http://10.0.2.2:5018/api
  // static String get baseUrl {
  //   if (kIsWeb) {
  //     return 'http://localhost:5018/api';
  //   } else if (defaultTargetPlatform == TargetPlatform.android) {
  //     return 'http://192.168.1.42/api';
  //   } else {
  //     return 'http://localhost:5018/api';
  //   }
  // }

  // // static  String baseUrl = 'http://192.168.1.42:5018';
  // static String baseHost = '$baseUrl/api';
  // static  String hubUrl = '$baseUrl/chatHub';


  static const String baseHost = 'http://192.168.1.42:5018';
  static const String baseUrl = '$baseHost/api';
  static const String hubUrl = '$baseHost/chatHub';

  // Chat Endpoints
  static String chatHistory(int projectId) => '$baseUrl/chat/$projectId/history';

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

  // TaskManage Endpoints
  static String get tasks => '$baseUrl/tasks';
  static String tasksByProject(int projectId) =>
      '$baseUrl/tasks/project/$projectId';
  static String taskDetail(int id) => '$baseUrl/tasks/$id';
  static String taskLookups(int projectId) =>
      '$baseUrl/tasks/lookups/$projectId';
  static String assignTask(int id) => '$baseUrl/tasks/$id/assign';
  static String taskAssignee(int id) => '$baseUrl/tasks/$id/assignee';
  static String selfAssignTask(int id) => '$baseUrl/tasks/$id/self-assign';

  static String get taskStatuses => '$baseUrl/task-statuses';
  static String taskStatus(int id) => '$baseUrl/task-statuses/$id';
}
