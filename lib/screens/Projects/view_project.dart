import 'package:flutter/material.dart';
import '../../core/services/project_service.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  List<dynamic> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() => _isLoading = true);
    final projects = await ProjectService.getAllProjects();
    setState(() {
      _projects = projects;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchProjects,
          child: Column(
            children: [
              const ProjectListHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _projects.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('Bạn chưa tham gia dự án nào'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            itemCount: _projects.length,
                            itemBuilder: (context, index) {
                              final project = _projects[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ProjectCard(
                                  title: project['projectName'] ?? 'No Name',
                                  status: project['statusName'] ?? 'Planning',
                                  role: project['userRole'] ?? 'Member',
                                  startDate: project['startDate'] != null 
                                      ? project['startDate'].toString().split('T')[0] 
                                      : 'N/A',
                                  endDate: project['endDate'] != null 
                                      ? project['endDate'].toString().split('T')[0] 
                                      : 'N/A',
                                  id: project['projectId'] ?? 0,
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/projects/new');
          if (result == true) _fetchProjects();
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
          const SizedBox(width: 40), // Placeholder for symmetry
        ],
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String status;
  final String role;
  final String startDate;
  final String endDate;
  final int id;

  const ProjectCard({
    super.key,
    required this.title,
    required this.status,
    required this.role,
    required this.startDate,
    required this.endDate,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = status == 'Completed' ? const Color(0xFF4ECDC4) : const Color(0xFFFFB347);
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/projects/detail', arguments: id);
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
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Color(0xFF6C63FF)),
                const SizedBox(width: 4),
                Text(
                  'Role: $role',
                  style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '$startDate - $endDate',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
