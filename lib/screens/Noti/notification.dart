import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NotificationHeader(),
            const NotificationFilterTabs(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: const [
                  NotificationCard(
                    title: 'Due soon: "Project Report...',
                    content: 'This task is due at 23:59 today. Would you like to update...',
                    time: '10 minutes ago',
                    icon: Icons.timer_outlined,
                    iconBgColor: Color(0xFFFFEBEB),
                    iconColor: Color(0xFFFF6B6B),
                    isUnread: true,
                  ),
                  SizedBox(height: 16),
                  NotificationCard(
                    title: 'Minh Anh mentioned you',
                    content: '" @you Please check the chart on page 3, the data seems...',
                    time: '2 hours ago',
                    avatarUrl: 'https://i.pravatar.cc/100?img=12',
                    isUnread: true,
                  ),
                  SizedBox(height: 16),
                  NotificationCard(
                    title: 'New task assigned',
                    content: 'You were assigned "Find reference materials for chapter 1" in...',
                    time: 'Yesterday, 14:30',
                    icon: Icons.assignment_outlined,
                    iconBgColor: Color(0xFFE8E4FF),
                    iconColor: Color(0xFF6C63FF),
                  ),
                  SizedBox(height: 16),
                  NotificationCard(
                    title: 'Congratulations! You completed...',
                    content: 'A productive week! Keep up the good work!',
                    time: 'Monday, 09:00',
                    icon: Icons.celebration_outlined,
                    iconBgColor: Color(0xFFF3F0FF),
                    iconColor: Color(0xFFB0B0B0),
                  ),
                  SizedBox(height: 100), // Space for Bottom Nav
                ],
              ),
            ),
          ],
        ),
      ),
      
    );
  }
}

class NotificationHeader extends StatelessWidget {
  const NotificationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          TextButton(
            onPressed: () {},
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
    );
  }
}

class NotificationFilterTabs extends StatelessWidget {
  const NotificationFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: const [
          FilterChipItem(label: 'All', isActive: true),
          SizedBox(width: 12),
          FilterChipItem(label: 'Unread'),
          SizedBox(width: 12),
          FilterChipItem(label: 'Reminders'),
        ],
      ),
    );
  }
}

class FilterChipItem extends StatelessWidget {
  final String label;
  final bool isActive;

  const FilterChipItem({super.key, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6C63FF) : const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF666666),
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String content;
  final String time;
  final IconData? icon;
  final Color? iconBgColor;
  final Color? iconColor;
  final String? avatarUrl;
  final bool isUnread;

  const NotificationCard({
    super.key,
    required this.title,
    required this.content,
    required this.time,
    this.icon,
    this.iconBgColor,
    this.iconColor,
    this.avatarUrl,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading Icon or Avatar
          if (avatarUrl != null)
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(avatarUrl!),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6C63FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 10),
                  ),
                ),
              ],
            )
          else
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor ?? const Color(0xFFF3F0FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon ?? Icons.notifications_none, color: iconColor ?? const Color(0xFF6C63FF), size: 24),
            ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
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
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 20),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          NavItem(icon: Icons.home_outlined, label: 'Home'),
          NavItem(icon: Icons.folder_outlined, label: 'PROJECT'),
          NavItem(icon: Icons.notifications_rounded, label: 'Notifications', isActive: true),
          NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
          NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const NavItem({super.key, required this.icon, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: isActive
              ? BoxDecoration(
            color: const Color(0xFFF3F0FF),
            borderRadius: BorderRadius.circular(16),
          )
              : null,
          child: Icon(icon, color: isActive ? const Color(0xFF6C63FF) : const Color(0xFFB0B0B0)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF6C63FF) : const Color(0xFFB0B0B0),
          ),
        ),
      ],
    );
  }
}
