class ApiConstants {
  // Use 10.0.2.2 for Android Emulator to connect to localhost on the host machine.
  // Use localhost (127.0.0.1) for iOS Simulator or Web.
  // Change to your machine's LAN IP if testing on a physical device, or use Ngrok URL.
  // The backend uses port 5018 for HTTP. We use HTTP for local dev to avoid certificate issues.
  static const String baseHost = 'http://192.168.1.42:5018';
  static const String baseUrl = '$baseHost/api';
  static const String hubUrl = '$baseHost/chatHub';

  // Chat Endpoints
  static String chatHistory(int projectId) => '$baseUrl/chat/$projectId/history';

  // Auth Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';

  // Project Endpoints
  static const String projects = '$baseUrl/projects';
  static String projectDetail(int id) => '$baseUrl/projects/$id';
  static String inviteMember(int id) => '$baseUrl/projects/$id/invite';
  static String leaveProject(int id) => '$baseUrl/projects/$id/leave';
  
  // Leave request handling (Guid based)
  static String approveLeaveRequest(String requestId) => '$baseUrl/projects/leave-requests/$requestId/approve';
  static String rejectLeaveRequest(String requestId) => '$baseUrl/projects/leave-requests/$requestId/reject';
}
