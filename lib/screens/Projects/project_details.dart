import 'package:flutter/material.dart';

class KanbanScreen extends StatelessWidget {
  const KanbanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      appBar: const KanbanAppBar(title: 'Graduation Thesis'),
      body: Column(
        children: const [
          KanbanTabs(),
          Expanded(child: KanbanBoard()),
        ],
      ),
      
    );
  }
}

class KanbanAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const KanbanAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)), onPressed: () { Navigator.pop(context); }),
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: const Color(0xFF6C63FF),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: Chip(
            label: const Text('In Progress', style: TextStyle(fontSize: 12)),
            backgroundColor: const Color(0xFFFFE8D1),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A1A)),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class KanbanTabs extends StatelessWidget {
  const KanbanTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: const [
            TabItem(label: 'Overview'),
            SizedBox(width: 24),
            TabItem(label: 'Kanban', isActive: true),
            SizedBox(width: 24),
            TabItem(label: 'Members'),
            SizedBox(width: 24),
            TabItem(label: 'Activity'),
          ],
        ),
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  final String label;
  final bool isActive;

  const TabItem({super.key, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF6C63FF) : const Color(0xFF666666),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 2,
            width: 40,
            color: const Color(0xFF6C63FF),
          ),
      ],
    );
  }
}

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: const [
        KanbanColumn(
          title: 'Backlog',
          taskCount: 2,
          tasks: [
            KanbanTaskCard(
              title: 'Market & Competitor Research',
              date: '25 Th10',
              priorityColor: Colors.red,
              assigneeAvatar: 'https://i.pravatar.cc/100?img=12',
            ),
            KanbanTaskCard(
              title: 'Draft User Personas',
              date: '28 Th10',
              priorityColor: Colors.orange,
              assigneeInitial: 'H',
            ),
          ],
        ),
        SizedBox(width: 20),
        KanbanColumn(
          title: 'In Progress',
          taskCount: 1,
          tasks: [
            KanbanTaskCard(
              title: 'Design main app UI/UX',
              date: 'Today',
              priorityColor: Colors.red,
              isOverdue: true,
            ),
          ],
        ),
      ],
    );
  }
}

class KanbanColumn extends StatelessWidget {
  final String title;
  final int taskCount;
  final List<Widget> tasks;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.taskCount,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$title ($taskCount)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20, color: Color(0xFF666666)),
                onPressed: () {
                  Navigator.pushNamed(context, '/tasks/new');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: tasks,
            ),
          ),
        ],
      ),
    );
  }
}

class KanbanTaskCard extends StatelessWidget {
  final String title;
  final String date;
  final Color priorityColor;
  final String? assigneeAvatar;
  final String? assigneeInitial;
  final bool isOverdue;

  const KanbanTaskCard({
    super.key,
    required this.title,
    required this.date,
    required this.priorityColor,
    this.assigneeAvatar,
    this.assigneeInitial,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/tasks/detail');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F0FF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverdue ? const Color(0xFFFFEBEB) : const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: isOverdue ? const Color(0xFFFF6B6B) : const Color(0xFF6C63FF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 10,
                        color: isOverdue ? const Color(0xFFFF6B6B) : const Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (assigneeAvatar != null)
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(assigneeAvatar!),
                )
              else if (assigneeInitial != null)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFFF3F0FF),
                  child: Text(
                    assigneeInitial!,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
                  ),
                ),
            ],
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
