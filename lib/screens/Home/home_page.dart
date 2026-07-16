import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WelcomeHeader(name: 'Minh', avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200'),
              const SizedBox(height: 24),
              const SummaryCardsRow(),
              const SizedBox(height: 32),
              const SectionHeader(title: 'My Projects', actionText: 'See All'),
              const SizedBox(height: 16),
              const ProjectHorizontalList(),
              const SizedBox(height: 32),
              const SectionHeader(title: 'Recent Tasks', actionText: 'Filters'),
              const SizedBox(height: 16),
              const RecentTasksList(),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      
    );
  }
}

class WelcomeHeader extends StatelessWidget {
  final String name;
  final String avatarUrl;

  const WelcomeHeader({super.key, required this.name, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning,', style: Theme.of(context).textTheme.bodyMedium),
                Text('$name! 👋', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(Icons.settings_outlined, color: Color(0xFF6C63FF)),
        ),
      ],
    );
  }
}

class SummaryCardsRow extends StatelessWidget {
  const SummaryCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SummaryCard(
          title: 'ACTIVE PROJECTS',
          count: '4',
          icon: Icons.folder_open_rounded,
          color: Color(0xFF6C63FF),
          isFullWidth: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              child: SummaryCard(
                title: "TODAY'S TASKS",
                count: '12',
                icon: Icons.check_circle_outline_rounded,
                color: Color(0xFF4ECDC4),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: SummaryCard(
                title: 'OVERDUE TASKS',
                count: '3',
                icon: Icons.error_outline_rounded,
                color: Color(0xFFFF6B6B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final bool isFullWidth;

  const SummaryCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFullWidth) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Text(
              count,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;

  const SectionHeader({super.key, required this.title, required this.actionText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        TextButton(
          onPressed: () {
            if (actionText == 'See All') {
              Navigator.pushNamed(context, '/projects');
            }
          },
          child: Text(
            actionText,
            style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class ProjectHorizontalList extends StatelessWidget {
  const ProjectHorizontalList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          ProjectCard(
            tag: 'Software',
            title: 'Graduation Thesis',
            date: '15/12/2023',
            progress: 0.65,
            status: 'Active',
          ),
          SizedBox(width: 16),
          ProjectCard(
            tag: 'Design',
            title: 'UI/UX App WellTask',
            date: '30/11/2023',
            progress: 0.85,
            status: 'Active',
            color: Color(0xFF8B4513),
          ),
        ],
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String tag;
  final String title;
  final String date;
  final double progress;
  final String status;
  final Color color;

  const ProjectCard({
    super.key,
    required this.tag,
    required this.title,
    required this.date,
    required this.progress,
    required this.status,
    this.color = const Color(0xFF6C63FF),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/projects/detail');
      },
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(tag, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.more_vert, color: Color(0xFFB0B0B0)),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFFB0B0B0)),
              const SizedBox(width: 4),
              Text(date, style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 12)),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progress', style: TextStyle(color: Color(0xFF666666), fontSize: 12)),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const MemberAvatarsRow(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Active', style: TextStyle(color: Color(0xFF4ECDC4), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}

class MemberAvatarsRow extends StatelessWidget {
  const MemberAvatarsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 3; i++)
          Align(
            widthFactor: 0.7,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 10,
                backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=${i + 10}'),
              ),
            ),
          ),
        Align(
          widthFactor: 0.7,
          child: CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: const Color(0xFFF3F0FF),
              child: const Text('+2', style: TextStyle(fontSize: 8, color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }
}

class RecentTasksList extends StatelessWidget {
  const RecentTasksList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        TaskItem(
          title: 'Finalize Wireframe',
          project: 'UI/UX WellTask',
          priority: 'High',
          priorityColor: Color(0xFFFF6B6B),
          deadline: 'Today',
          isDone: false,
        ),
        SizedBox(height: 12),
        TaskItem(
          title: 'Write Chapter 1 Report',
          project: 'Graduation Thesis',
          priority: 'TB',
          priorityColor: Color(0xFFFFB347),
          deadline: 'Tomorrow',
          isDone: false,
        ),
        SizedBox(height: 12),
        TaskItem(
          title: 'Submit Syllabus Outline',
          project: 'Graduation Thesis',
          priority: 'Low',
          priorityColor: Color(0xFFB0B0B0),
          deadline: 'Next Week',
          isDone: true,
        ),
      ],
    );
  }
}

class TaskItem extends StatelessWidget {
  final String title;
  final String project;
  final String priority;
  final Color priorityColor;
  final String deadline;
  final bool isDone;

  const TaskItem({
    super.key,
    required this.title,
    required this.project,
    required this.priority,
    required this.priorityColor,
    required this.deadline,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/tasks/detail');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
        children: [
          Checkbox(
            value: isDone,
            onChanged: (val) {},
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            activeColor: const Color(0xFF6C63FF),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? const Color(0xFFB0B0B0) : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        project,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF6C63FF)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time, size: 12, color: Color(0xFFFF6B6B)),
                        const SizedBox(width: 4),
                        Text(
                          deadline,
                          style: const TextStyle(fontSize: 10, color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(priority, style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33'),
          ),
        ],
      ),
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
          NavItem(icon: Icons.home_rounded, label: 'Home', isActive: true),
          NavItem(icon: Icons.folder_rounded, label: 'PROJECT'),
          NavItem(icon: Icons.notifications_rounded, label: 'Notifications'),
          NavItem(icon: Icons.chat_bubble_rounded, label: 'Chat'),
          NavItem(icon: Icons.person_rounded, label: 'Profile'),
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
          decoration: isActive ? BoxDecoration(
            color: const Color(0xFFF3F0FF),
            borderRadius: BorderRadius.circular(16),
          ) : null,
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
 