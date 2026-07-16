import 'package:flutter/material.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      body: SafeArea(
        child: Column(
          children: [
            const ProjectListHeader(),
            const SearchAndFilterBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: const [
                  ProjectCard(
                    title: 'Graduation Thesis',
                    status: 'In Progress',
                    statusColor: Color(0xFFFFB347),
                    startDate: '15/09',
                    endDate: '20/12',
                    completedTasks: 8,
                    totalTasks: 12,
                    progress: 0.65,
                    memberCount: 3,
                  ),
                  SizedBox(height: 16),
                  ProjectCard(
                    title: 'Artificial Intelligence Assignment',
                    status: 'Planning',
                    statusColor: Color(0xFF9E9E9E),
                    startDate: '01/11',
                    endDate: '30/11',
                    completedTasks: 0,
                    totalTasks: 5,
                    progress: 0.0,
                    memberCount: 1,
                  ),
                  SizedBox(height: 16),
                  ProjectCard(
                    title: 'Design UI/UX App WellTask',
                    status: 'Done',
                    statusColor: Color(0xFF4ECDC4),
                    startDate: '15/08',
                    endDate: '10/09',
                    completedTasks: 24,
                    totalTasks: 24,
                    progress: 1.0,
                    memberCount: 2,
                    isCompleted: true,
                  ),
                  SizedBox(height: 80), // Padding at bottom for spacing
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/projects/new');
        },
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

class ProjectListHeader extends StatelessWidget {
  const ProjectListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100'),
          ),
          Text(
            'WellTask',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF6C63FF)),
          ),
        ],
      ),
    );
  }
}

class SearchAndFilterBar extends StatelessWidget {
  const SearchAndFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search projects...',
              hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFB0B0B0)),
              filled: true,
              fillColor: const Color(0xFFF3F0FF),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: const [
              FilterChip(label: 'All', isActive: true),
              SizedBox(width: 8),
              FilterChip(label: 'Active'),
              SizedBox(width: 8),
              FilterChip(label: 'Completed'),
              SizedBox(width: 8),
              FilterChip(label: 'Archived'),
            ],
          ),
        ),
      ],
    );
  }
}

class FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const FilterChip({super.key, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6C63FF) : const Color(0xFFE0E0E0).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF666666),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final String startDate;
  final String endDate;
  final int completedTasks;
  final int totalTasks;
  final double progress;
  final int memberCount;
  final bool isCompleted;

  const ProjectCard({
    super.key,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.startDate,
    required this.endDate,
    required this.completedTasks,
    required this.totalTasks,
    required this.progress,
    required this.memberCount,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/projects/detail');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$startDate - $endDate',
            style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progress', style: TextStyle(color: Color(0xFF666666), fontSize: 13)),
              Text(
                '$completedTasks/$totalTasks task',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF3F0FF),
              valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? const Color(0xFF4ECDC4) : const Color(0xFF6C63FF)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MemberAvatars(count: memberCount),
              const Icon(Icons.more_horiz, color: Color(0xFFB0B0B0)),
            ],
          ),
        ],
      ),
    ),
  );
}
}

class MemberAvatars extends StatelessWidget {
  final int count;

  const MemberAvatars({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          for (int i = 0; i < (count > 3 ? 3 : count); i++)
            Align(
              widthFactor: 0.6,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 10,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=${i + 20}'),
                ),
              ),
            ),
          if (count > 3)
            Align(
              widthFactor: 0.6,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: const Color(0xFFF3F0FF),
                  child: Text(
                    '+${count - 3}',
                    style: const TextStyle(fontSize: 8, color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
                  ),
                ),
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