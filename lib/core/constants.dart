class ApiConstants {
  // Use 10.0.2.2 for Android Emulator to connect to localhost on the host machine.
  // Use localhost (127.0.0.1) for iOS Simulator or Web.
  // Change to your machine's LAN IP if testing on a physical device.
  // The backend uses port 5169 for HTTP and 7297 for HTTPS. We use HTTP for local dev to avoid certificate issues.
  static const String baseUrl = 'http://10.0.2.2:5169/api';

  // Auth Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
}
