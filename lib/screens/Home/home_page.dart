import 'package:flutter/material.dart';

import '../../core/services/project_service.dart';
import '../../core/services/task_service.dart';
import '../../core/services/user_service.dart';

const Color _primary = Color(0xFF6C63FF);
const Color _surface = Color(0xFFF8F9FF);
const Color _muted = Color(0xFF666666);
const Color _teal = Color(0xFF4ECDC4);
const Color _danger = Color(0xFFFF6B6B);

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

String _text(dynamic value, [String fallback = '']) {
  final text = value?.toString() ?? '';
  return text.trim().isEmpty ? fallback : text;
}

DateTime? _asDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool _sameDay(DateTime a, DateTime b) => _dateOnly(a) == _dateOnly(b);

String _statusKey(dynamic value) {
  return _text(value).toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

String _formatDate(dynamic value) {
  final date = _asDate(value);
  if (date == null) return 'No date';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String _relativeDueLabel(dynamic value) {
  final date = _asDate(value);
  if (date == null) return 'No due date';

  final today = _dateOnly(DateTime.now());
  final due = _dateOnly(date);
  final diff = due.difference(today).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff < 0) return '${diff.abs()}d overdue';
  if (diff <= 7) return 'In ${diff}d';
  return _formatDate(value);
}

bool _isDoneStatus(dynamic value) {
  final status = _statusKey(value);
  return status == 'done' || status == 'completed' || status == 'complete';
}

bool _isActiveProject(dynamic project) {
  final status = _text(project['statusName'] ?? project['StatusName']);
  return !_isDoneStatus(status);
}

Color _priorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return _danger;
    case 'medium':
    case 'normal':
      return const Color(0xFFFFB347);
    case 'low':
      return const Color(0xFF8E9AAF);
    default:
      return const Color(0xFFB0B0B0);
  }
}

Color _projectColor(int index) {
  const colors = [
    _primary,
    Color(0xFF008A63),
    Color(0xFFCB7A00),
    Color(0xFF2F80ED),
    Color(0xFF9B51E0),
  ];
  return colors[index % colors.length];
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _tasks = [];
  Map<int, List<Map<String, dynamic>>> _statusesByProject = {};

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profileResult = await UserService.getProfile();
      final projectsRaw = await ProjectService.getAllProjects();
      final projects = projectsRaw
          .whereType<Map>()
          .map((project) => Map<String, dynamic>.from(project))
          .toList();

      final boardResults = await Future.wait(
        projects.map((project) async {
          final projectId = _projectId(project);
          if (projectId == null) {
            return {
              'projectId': null,
              'tasks': <Map<String, dynamic>>[],
              'statuses': <Map<String, dynamic>>[],
            };
          }
          final projectName = _projectName(project);
          final results = await Future.wait([
            TaskService.getTasksByProject(projectId),
            TaskService.getLookups(projectId),
          ]);
          final rawTasks = results[0] as List<dynamic>;
          final lookups = results[1] as Map<String, dynamic>;
          final statuses = (lookups['statuses'] as List<dynamic>? ?? [])
              .whereType<Map>()
              .map((status) => Map<String, dynamic>.from(status))
              .toList();
          final tasks = rawTasks
              .whereType<Map>()
              .map((task) => Map<String, dynamic>.from(task))
              .map((task) => {...task, '_projectName': projectName})
              .toList();
          return {'projectId': projectId, 'tasks': tasks, 'statuses': statuses};
        }),
      );

      if (!mounted) return;
      final statusesByProject = <int, List<Map<String, dynamic>>>{};
      for (final result in boardResults) {
        final projectId = result['projectId'] as int?;
        if (projectId == null) continue;
        statusesByProject[projectId] =
            result['statuses'] as List<Map<String, dynamic>>;
      }
      setState(() {
        _profile = profileResult['success'] == true
            ? Map<String, dynamic>.from(profileResult['data'] as Map)
            : null;
        _projects = projects;
        _tasks = boardResults
            .expand((result) => result['tasks'] as List<Map<String, dynamic>>)
            .toList();
        _statusesByProject = statusesByProject;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  int? _projectId(Map<String, dynamic> project) {
    return _asInt(project['projectId'] ?? project['ProjectId']);
  }

  String _projectName(Map<String, dynamic> project) {
    return _text(
      project['projectName'] ?? project['ProjectName'],
      'Untitled Project',
    );
  }

  int? _taskId(Map<String, dynamic> task) {
    return _asInt(task['taskId'] ?? task['TaskId']);
  }

  DateTime? _taskDueDate(Map<String, dynamic> task) {
    return _asDate(task['dueDate'] ?? task['DueDate']);
  }

  DateTime? _taskCreatedAt(Map<String, dynamic> task) {
    return _asDate(task['createdAt'] ?? task['CreatedAt']);
  }

  String _taskStatus(Map<String, dynamic> task) {
    return _text(task['statusName'] ?? task['StatusName']);
  }

  int? _taskProjectId(Map<String, dynamic> task) {
    return _asInt(task['projectId'] ?? task['ProjectId']);
  }

  int? _taskStatusId(Map<String, dynamic> task) {
    return _asInt(task['taskStatusId'] ?? task['TaskStatusId']);
  }

  int? _statusIdByKey(int projectId, String key) {
    final statuses = _statusesByProject[projectId] ?? [];
    for (final status in statuses) {
      final name = status['statusName'] ?? status['StatusName'];
      if (_statusKey(name) == key) {
        return _asInt(status['taskStatusId'] ?? status['TaskStatusId']);
      }
    }
    return null;
  }

  String _statusNameById(int projectId, int statusId) {
    final statuses = _statusesByProject[projectId] ?? [];
    for (final status in statuses) {
      final id = _asInt(status['taskStatusId'] ?? status['TaskStatusId']);
      if (id == statusId) {
        return _text(status['statusName'] ?? status['StatusName']);
      }
    }
    return '';
  }

  int get _activeProjectCount => _projects.where(_isActiveProject).length;

  int get _todayTaskCount {
    final now = DateTime.now();
    return _tasks.where((task) {
      final dueDate = _taskDueDate(task);
      return dueDate != null && _sameDay(dueDate, now);
    }).length;
  }

  int get _overdueTaskCount {
    final today = _dateOnly(DateTime.now());
    return _tasks.where((task) {
      final dueDate = _taskDueDate(task);
      return dueDate != null &&
          _dateOnly(dueDate).isBefore(today) &&
          !_isDoneStatus(_taskStatus(task));
    }).length;
  }

  List<Map<String, dynamic>> get _recentTasks {
    final items = [..._tasks];
    items.sort((a, b) {
      final bDate = _taskCreatedAt(b) ?? _taskDueDate(b) ?? DateTime(1900);
      final aDate = _taskCreatedAt(a) ?? _taskDueDate(a) ?? DateTime(1900);
      return bDate.compareTo(aDate);
    });
    return items.take(5).toList();
  }

  String get _displayName {
    final raw =
        _profile?['fullName'] ??
        _profile?['FullName'] ??
        _profile?['name'] ??
        _profile?['email'] ??
        _profile?['Email'];
    final fullName = _text(raw, 'User');
    return fullName.contains('@') ? fullName.split('@').first : fullName;
  }

  String? get _avatarUrl {
    final avatar = _text(_profile?['avatarUrl'] ?? _profile?['AvatarUrl']);
    return avatar.isEmpty ? null : avatar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: RefreshIndicator(
          color: _primary,
          onRefresh: _loadHome,
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: _primary))
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WelcomeHeader(name: _displayName, avatarUrl: _avatarUrl),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        ErrorBanner(message: _error!, onRetry: _loadHome),
                      ],
                      const SizedBox(height: 24),
                      SummaryCardsRow(
                        activeProjects: _activeProjectCount,
                        todayTasks: _todayTaskCount,
                        overdueTasks: _overdueTaskCount,
                      ),
                      const SizedBox(height: 32),
                      const SectionHeader(
                        title: 'My Projects',
                        actionText: 'See All',
                      ),
                      const SizedBox(height: 16),
                      ProjectHorizontalList(projects: _projects, tasks: _tasks),
                      const SizedBox(height: 32),
                      const SectionHeader(
                        title: 'Recent Tasks',
                        actionText: 'View Board',
                      ),
                      const SizedBox(height: 16),
                      RecentTasksList(
                        tasks: _recentTasks,
                        onTaskTap: _openTask,
                        onDoneChanged: _toggleTaskDone,
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _openTask(Map<String, dynamic> task) {
    final taskId = _taskId(task);
    if (taskId == null) return;
    Navigator.pushNamed(context, '/tasks/detail', arguments: {'task': task});
  }

  Future<void> _toggleTaskDone(Map<String, dynamic> task, bool done) async {
    final taskId = _taskId(task);
    final projectId = _taskProjectId(task);
    if (taskId == null || projectId == null) return;

    final statusId = _statusIdByKey(projectId, done ? 'done' : 'todo');
    if (statusId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            done ? 'Done status was not found.' : 'To Do status was not found.',
          ),
        ),
      );
      return;
    }

    final oldStatusId = _taskStatusId(task);
    final oldStatusName = _taskStatus(task);
    final nextStatusName = _statusNameById(projectId, statusId);

    setState(() {
      _tasks = _tasks
          .map(
            (item) => _taskId(item) == taskId
                ? {
                    ...item,
                    'taskStatusId': statusId,
                    'statusName': nextStatusName,
                  }
                : item,
          )
          .toList();
    });

    final result = await TaskService.moveTask(taskId, statusId);
    if (!mounted) return;

    if (result['success'] != true) {
      setState(() {
        _tasks = _tasks
            .map(
              (item) => _taskId(item) == taskId
                  ? {
                      ...item,
                      'taskStatusId': oldStatusId,
                      'statusName': oldStatusName,
                    }
                  : item,
            )
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Could not update task.')),
      );
    } else {
      await _loadHome();
    }
  }
}

class WelcomeHeader extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const WelcomeHeader({super.key, required this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'U' : name.trim()[0].toUpperCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFEDEBFF),
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      initial,
                      style: const TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning,',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '$name!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/profile'),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.settings_outlined, color: _primary),
        ),
      ],
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorBanner({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _danger.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: _danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _danger, fontSize: 12),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class SummaryCardsRow extends StatelessWidget {
  final int activeProjects;
  final int todayTasks;
  final int overdueTasks;

  const SummaryCardsRow({
    super.key,
    required this.activeProjects,
    required this.todayTasks,
    required this.overdueTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SummaryCard(
          title: 'ACTIVE PROJECTS',
          count: activeProjects.toString(),
          icon: Icons.folder_open_rounded,
          color: _primary,
          isFullWidth: true,
          onTap: () => Navigator.pushNamed(context, '/projects'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                title: "TODAY'S TASKS",
                count: todayTasks.toString(),
                icon: Icons.check_circle_outline_rounded,
                color: _teal,
                onTap: () => Navigator.pushNamed(context, '/tasks'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                title: 'OVERDUE TASKS',
                count: overdueTasks.toString(),
                icon: Icons.error_outline_rounded,
                color: _danger,
                onTap: () => Navigator.pushNamed(context, '/tasks'),
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
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.isFullWidth = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: EdgeInsets.all(isFullWidth ? 20 : 16),
      decoration: BoxDecoration(
        color: isFullWidth ? Colors.white : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: isFullWidth
            ? null
            : Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: isFullWidth
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: isFullWidth
          ? Row(
              children: [
                _SummaryIcon(icon: icon, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryTitle(title: title, color: color),
                ),
                _SummaryCount(count: count, color: color),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SummaryIcon(icon: icon, color: color, compact: true),
                    _SummaryCount(count: count, color: color, compact: true),
                  ],
                ),
                const SizedBox(height: 12),
                _SummaryTitle(title: title, color: color, compact: true),
              ],
            ),
    );

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: child,
    );
  }
}

class _SummaryIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool compact;

  const _SummaryIcon({
    required this.icon,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
      ),
      child: Icon(icon, color: color, size: compact ? 20 : 24),
    );
  }
}

class _SummaryTitle extends StatelessWidget {
  final String title;
  final Color color;
  final bool compact;

  const _SummaryTitle({
    required this.title,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: compact ? 10 : 12,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SummaryCount extends StatelessWidget {
  final String count;
  final Color color;
  final bool compact;

  const _SummaryCount({
    required this.count,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      count,
      style: TextStyle(
        fontSize: compact ? 24 : 28,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;

  const SectionHeader({
    super.key,
    required this.title,
    required this.actionText,
  });

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
            } else {
              Navigator.pushNamed(context, '/tasks');
            }
          },
          child: Text(
            actionText,
            style: const TextStyle(
              color: _primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class ProjectHorizontalList extends StatelessWidget {
  final List<Map<String, dynamic>> projects;
  final List<Map<String, dynamic>> tasks;

  const ProjectHorizontalList({
    super.key,
    required this.projects,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_open_rounded,
        title: 'No projects yet',
        message: 'Create or join a project to see it here.',
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: projects.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final project = projects[index];
          final projectId = _asInt(
            project['projectId'] ?? project['ProjectId'],
          );
          final projectTasks = tasks
              .where(
                (task) =>
                    _asInt(task['projectId'] ?? task['ProjectId']) == projectId,
              )
              .toList();
          final doneCount = projectTasks
              .where(
                (task) =>
                    _isDoneStatus(task['statusName'] ?? task['StatusName']),
              )
              .length;
          final progress = projectTasks.isEmpty
              ? 0.0
              : doneCount / projectTasks.length;

          return ProjectCard(
            id: projectId,
            tag: _text(project['userRole'] ?? project['UserRole'], 'Member'),
            title: _text(
              project['projectName'] ?? project['ProjectName'],
              'Untitled Project',
            ),
            date: _formatDate(
              project['endDate'] ??
                  project['EndDate'] ??
                  project['startDate'] ??
                  project['StartDate'],
            ),
            progress: progress,
            status: _text(
              project['statusName'] ?? project['StatusName'],
              'N/A',
            ),
            color: _projectColor(index),
            taskCount: projectTasks.length,
          );
        },
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final int? id;
  final String tag;
  final String title;
  final String date;
  final double progress;
  final String status;
  final Color color;
  final int taskCount;

  const ProjectCard({
    super.key,
    required this.id,
    required this.tag,
    required this.title,
    required this.date,
    required this.progress,
    required this.status,
    required this.taskCount,
    this.color = _primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: id == null
          ? null
          : () {
              Navigator.pushNamed(context, '/projects/detail', arguments: id);
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
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Text(
                  '$taskCount tasks',
                  style: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Color(0xFFB0B0B0),
                ),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _isDoneStatus(status)
                      ? const Color(0xFFECEFF5)
                      : const Color(0xFFE0F7F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _isDoneStatus(status) ? _muted : _teal,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentTasksList extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final ValueChanged<Map<String, dynamic>> onTaskTap;
  final void Function(Map<String, dynamic> task, bool done) onDoneChanged;

  const RecentTasksList({
    super.key,
    required this.tasks,
    required this.onTaskTap,
    required this.onDoneChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.task_alt_rounded,
        title: 'No tasks yet',
        message: 'Tasks from your projects will appear here.',
      );
    }

    return Column(
      children: [
        for (final task in tasks) ...[
          TaskItem(
            task: task,
            onTap: () => onTaskTap(task),
            onDoneChanged: (done) => onDoneChanged(task, done),
          ),
          if (task != tasks.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class TaskItem extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onTap;
  final ValueChanged<bool> onDoneChanged;

  const TaskItem({
    super.key,
    required this.task,
    required this.onTap,
    required this.onDoneChanged,
  });

  @override
  Widget build(BuildContext context) {
    final title = _text(task['title'] ?? task['Title'], 'Untitled task');
    final project = _text(task['_projectName'], 'Project');
    final priority = _text(
      task['priorityName'] ?? task['PriorityName'],
      'None',
    );
    final status = _text(task['statusName'] ?? task['StatusName']);
    final isDone = _isDoneStatus(status);
    final priorityColor = _priorityColor(priority);
    final assigneeAvatar = _text(
      task['assigneeAvatarUrl'] ?? task['AssigneeAvatarUrl'],
    );
    final assigneeName = _text(
      task['assigneeFullName'] ??
          task['AssigneeFullName'] ??
          task['assigneeEmail'] ??
          task['AssigneeEmail'],
      'Unassigned',
    );

    return GestureDetector(
      onTap: onTap,
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
              onChanged: (value) => onDoneChanged(value ?? false),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              activeColor: _primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _TaskChip(
                        label: project,
                        color: _primary,
                        background: const Color(0xFFF3F0FF),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: _danger,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _relativeDueLabel(
                              task['dueDate'] ?? task['DueDate'],
                            ),
                            style: const TextStyle(
                              fontSize: 10,
                              color: _danger,
                              fontWeight: FontWeight.bold,
                            ),
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
              child: Text(
                priority,
                style: TextStyle(
                  color: priorityColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFFEDEBFF),
              backgroundImage: assigneeAvatar.isNotEmpty
                  ? NetworkImage(assigneeAvatar)
                  : null,
              child: assigneeAvatar.isEmpty
                  ? Text(
                      assigneeName == 'Unassigned'
                          ? '-'
                          : assigneeName[0].toUpperCase(),
                      style: const TextStyle(
                        color: _primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _TaskChip({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFB0B0B0), size: 36),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 12),
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          NavItem(icon: Icons.home_rounded, label: 'Home', isActive: true),
          NavItem(icon: Icons.folder_rounded, label: 'Projects'),
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

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
  });

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
          child: Icon(
            icon,
            color: isActive ? _primary : const Color(0xFFB0B0B0),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? _primary : const Color(0xFFB0B0B0),
          ),
        ),
      ],
    );
  }
}
