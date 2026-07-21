import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use 10.0.2.2 for Android Emulator to connect to localhost on the host machine.
  // Use localhost (127.0.0.1) for iOS Simulator or Web.
  // Change to your machine's LAN IP if testing on a physical device.
  // The backend uses port 5018 for HTTP and 7297 for HTTPS. We use HTTP for local dev to avoid certificate issues.
  static const String baseUrl =
      kIsWeb ? 'http://localhost:5018/api' : 'http://10.0.2.2:5018/api';

  // Auth Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';

  // Project Endpoints
  static const String projects = '$baseUrl/projects';
  static String projectDetail(int id) => '$baseUrl/projects/$id';
  static String inviteMember(int id) => '$baseUrl/projects/$id/invite';
  static String leaveProject(int id) => '$baseUrl/projects/$id/leave';

  // Leave request handling (Guid based)
  static String approveLeaveRequest(String requestId) =>
      '$baseUrl/projects/leave-requests/$requestId/approve';
  static String rejectLeaveRequest(String requestId) =>
      '$baseUrl/projects/leave-requests/$requestId/reject';

  // TaskManage Endpoints
  static const String tasks = '$baseUrl/tasks';
  static String tasksByProject(int projectId) =>
      '$baseUrl/tasks/project/$projectId';
  static String taskDetail(int id) => '$baseUrl/tasks/$id';
  static String taskLookups(int projectId) =>
      '$baseUrl/tasks/lookups/$projectId';
  static String assignTask(int id) => '$baseUrl/tasks/$id/assign';
  static String taskAssignee(int id) => '$baseUrl/tasks/$id/assignee';
  static String selfAssignTask(int id) => '$baseUrl/tasks/$id/self-assign';

  static const String taskStatuses = '$baseUrl/task-statuses';
  static String taskStatus(int id) => '$baseUrl/task-statuses/$id';
}
