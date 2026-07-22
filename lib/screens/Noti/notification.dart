import 'package:flutter/material.dart';
import '../../core/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _svc = NotificationService();

  @override
  void initState() {
    super.initState();
    _svc.addListener(_rebuild);
    _svc.fetchNotifications();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _svc.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _svc.all;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notifications', style: Theme.of(context).textTheme.headlineLarge),
                      if (_svc.unreadCount > 0)
                        Text(
                          '${_svc.unreadCount} unread',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6C63FF)),
                        onPressed: () => _svc.fetchNotifications(),
                      ),
                      if (_svc.unreadCount > 0)
                        TextButton(
                          onPressed: () => _svc.markAllRead(),
                          child: const Text(
                            'Mark all\nas read',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: _svc.isLoading && notifications.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
                  : notifications.isEmpty
                      ? RefreshIndicator(
                          onRefresh: () => _svc.fetchNotifications(),
                          color: const Color(0xFF6C63FF),
                          child: ListView(
                            children: [
                              const SizedBox(height: 100),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.shade300),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No notifications yet.',
                                      style: TextStyle(color: Color(0xFF999999), fontSize: 15),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Task assignments and project invites will appear here.',
                                      style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _svc.fetchNotifications(),
                          color: const Color(0xFF6C63FF),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: notifications.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final n = notifications[index];
                              return GestureDetector(
                                onTap: () => _svc.markRead(n.id),
                                child: _NotificationCard(
                                  title: n.title,
                                  content: n.body,
                                  time: _formatTime(n.time),
                                  isUnread: !n.isRead,
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes} minutes ago';
    if (diff.inDays < 1) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─── Card ─────────────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final String title;
  final String content;
  final String time;
  final bool isUnread;

  const _NotificationCard({
    required this.title,
    required this.content,
    required this.time,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFF3F0FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active_outlined, color: Color(0xFF6C63FF), size: 24),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6C63FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFFB0B0B0))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
