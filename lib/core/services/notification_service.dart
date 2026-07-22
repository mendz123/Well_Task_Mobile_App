import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api_client.dart';
import '../constants.dart';
import 'auth_service.dart';

/// Model thông báo
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
  });
}

/// Singleton service quản lý thông báo trong app.
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get all => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Lấy thông báo thực từ OData BE
  Future<void> fetchNotifications() async {
    final userId = await AuthService.getUserId();
    if (userId <= 0) return;
    _isLoading = true;
    notifyListeners();

    try {
      final url = ApiConstants.odataNotifications(userId);
      final response = await ApiClient.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['value'] ?? [];
        _notifications.clear();
        for (final item in list) {
          final id = item['notificationId'] ?? item['NotificationId'] ?? 0;
          final msg = item['message'] ?? item['Message'] ?? 'Notification';
          final isRead = item['isRead'] ?? item['IsRead'] ?? false;
          final createdAtRaw = item['createdAt'] ?? item['CreatedAt'];
          final dt = createdAtRaw != null
              ? (DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now())
              : DateTime.now();

          _notifications.add(AppNotification(
            id: id.toString(),
            title: 'WellTask Alert',
            body: msg.toString(),
            time: dt,
            isRead: isRead == true,
          ));
        }
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  /// Gọi khi ứng dụng tạo ra sự kiện thông báo tại chỗ
  void addNotification({required String title, required String body}) {
    _notifications.insert(
      0,
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        time: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<void> markAllRead() async {
    for (final n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        _patchIsRead(n.id);
      }
    }
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx].isRead = true;
      _patchIsRead(id);
      notifyListeners();
    }
  }

  Future<void> _patchIsRead(String id) async {
    final numId = int.tryParse(id);
    if (numId == null || numId <= 0) return;
    try {
      final url = ApiConstants.odataNotificationPatch(numId);
      await ApiClient.patch(url, {'isRead': true});
    } catch (_) {}
  }
}
