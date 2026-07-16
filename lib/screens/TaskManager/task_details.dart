import 'package:flutter/material.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      appBar: const TaskDetailAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TaskHeader(
              breadcrumb: 'PROJECT / Design App',
              group: 'Team',
              title: 'Design UI for Task Detail & Dashboard',
            ),
            const SizedBox(height: 24),
            const StatusSection(),
            const SizedBox(height: 24),
            const InfoCard(
              title: 'DESCRIPTION',
              content:
              'Complete UI design for 2 main screens. Follow new Design System (Airy Minimalism). Need clear component library and responsive states.',
            ),
            const SizedBox(height: 20),
            const SubtaskSection(
              total: 3,
              completed: 1,
              subtasks: [
                SubtaskItem(title: 'Reference Research (Notion, Linear)', isDone: true),
                SubtaskItem(title: 'Draft Wireframe for Detail Screen', isDone: false),
                SubtaskItem(title: 'Apply UI Kit to Wireframe', isDone: false),
              ],
            ),
            const SizedBox(height: 20),
            const AssigneeSection(
              assignees: [
                {'name': 'Linh N.', 'avatar': 'https://i.pravatar.cc/100?img=32'},
                {'name': 'Minh T.', 'avatar': 'https://i.pravatar.cc/100?img=12'},
              ],
            ),
            const SizedBox(height: 20),
            const SkillsSection(
              skills: ['UI Design', 'Figma', 'Design System'],
            ),
            const SizedBox(height: 32),
            const CommentSection(),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
      
    );
  }
}

class TaskDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TaskDetailAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)), onPressed: () { Navigator.pop(context); }),
      title: const Text(
        'WellTask',
        style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF666666)),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class TaskHeader extends StatelessWidget {
  final String breadcrumb;
  final String group;
  final String title;

  const TaskHeader({
    super.key,
    required this.breadcrumb,
    required this.group,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(breadcrumb, style: const TextStyle(fontSize: 12, color: Color(0xFFB0B0B0))),
        Text(group, style: const TextStyle(fontSize: 12, color: Color(0xFF666666), fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }
}

class StatusSection extends StatelessWidget {
  const StatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE8E4FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Expanded(child: StatusChip(label: 'In Progress', isActive: true)),
              const Expanded(child: StatusChip(label: 'Not Started')),
              const Expanded(child: StatusChip(label: 'Completed')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.flag_rounded, color: Color(0xFFFF6B6B), size: 16),
                  SizedBox(width: 4),
                  Text('High', style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.calendar_today_rounded, color: Color(0xFF6C63FF), size: 16),
                  SizedBox(width: 4),
                  Text('Today, 11:59 PM', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const StatusChip({super.key, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: isActive
          ? BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
      )
          : null,
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? const Color(0xFF6C63FF) : const Color(0xFF666666),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(content, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class SubtaskSection extends StatelessWidget {
  final int total;
  final int completed;
  final List<SubtaskItem> subtasks;

  const SubtaskSection({
    super.key,
    required this.total,
    required this.completed,
    required this.subtasks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SUBTASKS', style: Theme.of(context).textTheme.titleLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$completed/$total Completed', style: const TextStyle(fontSize: 10, color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...subtasks,
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add SUBTASKS'),
            style: TextButton.styleFrom(foregroundColor: Color(0xFF6C63FF)),
          ),
        ],
      ),
    );
  }
}

class SubtaskItem extends StatelessWidget {
  final String title;
  final bool isDone;

  const SubtaskItem({super.key, required this.title, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? const Color(0xFF6C63FF) : const Color(0xFFB0B0B0),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isDone ? const Color(0xFFB0B0B0) : const Color(0xFF1A1A1A),
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AssigneeSection extends StatelessWidget {
  final List<Map<String, String>> assignees;

  const AssigneeSection({super.key, required this.assignees});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ASSIGNEE', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...assignees.map((a) => Chip(
                avatar: CircleAvatar(backgroundImage: NetworkImage(a['avatar']!)),
                label: Text(a['name']!, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () {},
                backgroundColor: const Color(0xFFF3F0FF),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              )),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF6C63FF), style: BorderStyle.solid),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add_outlined, size: 16, color: Color(0xFF6C63FF)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SkillsSection extends StatelessWidget {
  final List<String> skills;

  const SkillsSection({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F0FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('REQUIRED SKILLS', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...skills.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(s, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFB0B0B0), style: BorderStyle.none),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add, size: 14, color: Color(0xFFB0B0B0)),
                    SizedBox(width: 4),
                    Text('Add', style: TextStyle(fontSize: 12, color: Color(0xFFB0B0B0))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CommentSection extends StatelessWidget {
  const CommentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comments', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        const CommentItem(
          name: 'Minh',
          time: '2 hours ago',
          avatar: 'https://i.pravatar.cc/100?img=12',
          message: 'I have uploaded the 2 latest screens!',
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
          ),
          child: Row(
            children: [
              const CircleAvatar(radius: 16, backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=33')),
              const SizedBox(width: 12),
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Add Comments...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14, color: Color(0xFFB0B0B0)),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.send_rounded, color: Color(0xFF6C63FF)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CommentItem extends StatelessWidget {
  final String name;
  final String time;
  final String avatar;
  final String message;

  const CommentItem({
    super.key,
    required this.name,
    required this.time,
    required this.avatar,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 16, backgroundImage: NetworkImage(avatar)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFFB0B0B0))),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(message, style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ],
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
          NavItem(icon: Icons.folder_rounded, label: 'PROJECT', isActive: true),
          NavItem(icon: Icons.notifications_none_rounded, label: 'Notifications'),
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
