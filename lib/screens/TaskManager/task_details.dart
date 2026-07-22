import 'package:flutter/material.dart';
import '../../core/services/task_service.dart';

const Color _primary = Color(0xFF6C63FF);
const Color _surface = Color(0xFFFCF8FF);
const Color _softBorder = Color(0xFFF3F0FF);

int? _asInt(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

String _text(dynamic value, [String fallback = '']) {
  final text = value?.toString() ?? '';
  return text.trim().isEmpty ? fallback : text;
}

String _dateOnly(dynamic value) {
  if (value == null) return 'No due date';
  return value.toString().split('T').first;
}

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _initialized = false;
  Map<String, dynamic>? _task;
  int? _projectId;
  String _projectName = 'TaskManage';
  List<dynamic> _statuses = [];
  List<dynamic> _priorities = [];
  List<dynamic> _members = [];
  List<dynamic> _epics = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final rawTask = args['task'];
      if (rawTask is Map<String, dynamic>) _task = rawTask;
      _projectId = _asInt(args['projectId']);
      _projectName = _text(args['projectName'], 'TaskManage');
      _statuses = args['statuses'] as List<dynamic>? ?? [];
      _priorities = args['priorities'] as List<dynamic>? ?? [];
      _members = args['members'] as List<dynamic>? ?? [];
      _epics = args['epics'] as List<dynamic>? ?? [];
    }
  }

  int _taskId() => _asInt(_task?['taskId'] ?? _task?['TaskId']) ?? 0;
  int? _statusId() => _asInt(_task?['taskStatusId'] ?? _task?['TaskStatusId']);
  int? _assigneeId() => _asInt(_task?['assigneeId'] ?? _task?['AssigneeId']);

  String _title() => _text(_task?['title'] ?? _task?['Title'], 'Untitled task');
  String _description() =>
      _text(_task?['description'] ?? _task?['Description'], 'No description.');
  String _statusName() =>
      _text(_task?['statusName'] ?? _task?['StatusName'], 'Unknown');
  String _priorityName() =>
      _text(_task?['priorityName'] ?? _task?['PriorityName'], 'No priority');
  String _assigneeName() {
    return _text(
      _task?['assigneeFullName'] ??
          _task?['AssigneeFullName'] ??
          _task?['assigneeEmail'] ??
          _task?['AssigneeEmail'],
      'Unassigned',
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _edit() async {
    final result = await Navigator.pushNamed(
      context,
      '/tasks/new',
      arguments: {
        'mode': 'edit',
        'task': _task,
        'projectId': _projectId,
        'projectName': _projectName,
        'statuses': _statuses,
        'priorities': _priorities,
        'members': _members,
        'epics': _epics,
      },
    );
    if (!mounted) return;
    if (result == true) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task'),
        content: Text('Delete "${_title()}"? This will soft-delete the task.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final result = await TaskService.deleteTask(_taskId());
    if (!mounted) return;
    if (result['success'] == true) {
      Navigator.pop(context, true);
    } else {
      _snack(result['message'] ?? 'Could not delete this task');
    }
  }

  Future<void> _move(int statusId) async {
    final result = await TaskService.moveTask(_taskId(), statusId);
    if (!mounted) return;
    if (result['success'] == true) {
      Navigator.pop(context, true);
    } else {
      _snack(result['message'] ?? 'Could not move this task');
    }
  }

  Future<void> _selfAssign() async {
    final result = await TaskService.selfAssignTask(_taskId());
    if (!mounted) return;
    if (result['success'] == true) {
      Navigator.pop(context, true);
    } else {
      _snack(result['message'] ?? 'Could not self-assign this task');
    }
  }

  Future<void> _unassign() async {
    final result = await TaskService.unassignTask(_taskId());
    if (!mounted) return;
    if (result['success'] == true) {
      Navigator.pop(context, true);
    } else {
      _snack(result['message'] ?? 'Could not remove assignee');
    }
  }

  void _showMoveSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Move task to status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ..._statuses.map((status) {
              final id =
                  _asInt(status['taskStatusId'] ?? status['TaskStatusId']) ?? 0;
              final name = _text(
                status['statusName'] ?? status['StatusName'],
                'Status',
              );
              return ListTile(
                leading: Icon(
                  id == _statusId()
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: _primary,
                ),
                title: Text(name),
                onTap: () {
                  Navigator.pop(context);
                  _move(id);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = _task;
    if (task == null) {
      return const Scaffold(body: Center(child: Text('Task not found.')));
    }

    final isSubTask =
        _asInt(task['parentTaskId'] ?? task['ParentTaskId']) != null;

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: const Text(
          'Task Detail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _edit),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'move') _showMoveSheet();
              if (value == 'delete') _delete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'move', child: Text('Move status')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _projectName.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                label: isSubTask ? 'SUB-TASK' : 'EPIC',
                color: isSubTask ? const Color(0xFF4ECDC4) : _primary,
              ),
              _Badge(label: _statusName(), color: _primary),
              _Badge(label: _priorityName(), color: Colors.orange),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _title(),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _InfoCard(
            title: 'Description',
            child: Text(
              _description(),
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
          _InfoCard(
            title: 'Schedule',
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: _primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _dateOnly(task['dueDate'] ?? task['DueDate']),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _InfoCard(
            title: 'Assignee',
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      _text(
                        task['assigneeAvatarUrl'] ?? task['AssigneeAvatarUrl'],
                      ).isNotEmpty
                      ? NetworkImage(
                          _text(
                            task['assigneeAvatarUrl'] ??
                                task['AssigneeAvatarUrl'],
                          ),
                        )
                      : null,
                  child: _assigneeId() == null
                      ? const Icon(Icons.person_outline)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _assigneeName(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (_assigneeId() == null)
                  TextButton.icon(
                    onPressed: _selfAssign,
                    icon: const Icon(Icons.person_add_alt),
                    label: const Text('Claim'),
                  )
                else
                  TextButton.icon(
                    onPressed: _unassign,
                    icon: const Icon(Icons.person_remove_alt_1),
                    label: const Text('Remove'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
