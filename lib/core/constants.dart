import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ApiConstants {
  // Automatically select the correct base host based on platform:
  // - Web / Desktop / iOS Simulator: http://localhost:5018
  // - Android Emulator / Device: http://10.0.2.2:5018 or http://192.168.1.42:5018
  static String get baseHost {
    if (kIsWeb) {
      return 'http://localhost:5018';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.1.42:5018';
    } else {
      return 'http://localhost:5018';
    }
  }

  static String get baseUrl => '$baseHost/api';
  static String get hubUrl => '$baseHost/chatHub';

  // Chat Endpoints
  static String chatHistory(int projectId) => '$baseUrl/chat/$projectId/history';

  // Google Client ID
  static String get googleClientId =>
      dotenv.env['GOOGLE_CLIENT_ID'] ?? '';

  // Auth Endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get googleLogin => '$baseUrl/auth/google-login';

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

  // Comments Endpoints (OData - under baseHost, not baseUrl)
  static String get comments => '$baseHost/odata/Comments';
  static String commentsByTask(int taskId) => '$baseHost/odata/Comments?\$filter=TaskId eq $taskId&\$expand=User(\$expand=UserProfile)&\$orderby=CreatedAt asc';
  static String commentDetail(int commentId) => '$baseHost/odata/Comments($commentId)';

  // Notifications Endpoints (OData - under baseHost, not baseUrl)
  static String odataNotifications(int userId) => '$baseHost/odata/Notifications?\$filter=UserId eq $userId&\$orderby=CreatedAt desc';
  static String odataNotificationPatch(int id) => '$baseHost/odata/Notifications($id)';
}
