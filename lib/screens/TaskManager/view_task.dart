import 'package:flutter/material.dart';
import '../../core/services/project_service.dart';
import '../../core/services/task_service.dart';

const Color _primary = Color(0xFF6C63FF);
const Color _surface = Color(0xFFFCF8FF);
const Color _softBorder = Color(0xFFF3F0FF);

int? _asInt(dynamic value) {
  if (value == null) return null;
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

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  int? _projectId;
  String _projectName = 'TaskManage';
  bool _loading = true;
  bool _loadingProjects = false;
  List<dynamic> _projects = [];
  List<dynamic> _tasks = [];
  List<dynamic> _statuses = [];
  List<dynamic> _priorities = [];
  List<dynamic> _members = [];
  int? _selectedStatusId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_projectId != null) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      _projectId = args;
    } else if (args is Map) {
      _projectId = _asInt(args['projectId']);
      _projectName = _text(args['projectName'], 'TaskManage');
    }

    if (_projectId != null) {
      _loadBoard();
    } else {
      _loadProjects();
    }
  }

  Future<void> _loadProjects() async {
    setState(() {
      _loading = false;
      _loadingProjects = true;
    });
    final projects = await ProjectService.getAllProjects();
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _loadingProjects = false;
    });
  }

  void _selectProject(dynamic project) {
    setState(() {
      _projectId = _asInt(project['projectId'] ?? project['ProjectId']);
      _projectName = _text(
        project['projectName'] ?? project['ProjectName'],
        'TaskManage',
      );
      _selectedStatusId = null;
    });
    if (_projectId != null) _loadBoard();
  }

  Future<void> _loadBoard() async {
    setState(() => _loading = true);
    final projectId = _projectId!;
    final results = await Future.wait([
      TaskService.getTasksByProject(projectId),
      TaskService.getLookups(projectId),
    ]);

    if (!mounted) return;
    final lookups = results[1] as Map<String, dynamic>;
    final statuses = lookups['statuses'] as List<dynamic>? ?? [];

    setState(() {
      _tasks = results[0] as List<dynamic>;
      _statuses = statuses;
      _priorities = lookups['priorities'] as List<dynamic>? ?? [];
      _members = lookups['members'] as List<dynamic>? ?? [];
      _selectedStatusId ??= statuses.isNotEmpty
          ? _statusId(statuses.first)
          : null;
      _loading = false;
    });
  }

  int _taskId(dynamic task) => _asInt(task['taskId'] ?? task['TaskId']) ?? 0;
  int _statusId(dynamic status) =>
      _asInt(status['taskStatusId'] ?? status['TaskStatusId']) ?? 0;
  int? _taskStatusId(dynamic task) =>
      _asInt(task['taskStatusId'] ?? task['TaskStatusId']);
  int? _assigneeId(dynamic task) =>
      _asInt(task['assigneeId'] ?? task['AssigneeId']);

  String _statusName(dynamic status) =>
      _text(status['statusName'] ?? status['StatusName'], 'Untitled');
  String _taskTitle(dynamic task) =>
      _text(task['title'] ?? task['Title'], 'Untitled task');
  String _taskDescription(dynamic task) =>
      _text(task['description'] ?? task['Description']);
  String _priorityName(dynamic task) =>
      _text(task['priorityName'] ?? task['PriorityName']);
  String _assigneeName(dynamic task) {
    return _text(
      task['assigneeFullName'] ??
          task['AssigneeFullName'] ??
          task['assigneeEmail'] ??
          task['AssigneeEmail'],
      'Unassigned',
    );
  }

  List<dynamic> get _visibleTasks {
    if (_selectedStatusId == null) return _tasks;
    return _tasks
        .where((task) => _taskStatusId(task) == _selectedStatusId)
        .toList();
  }

  List<dynamic> get _epics {
    return _tasks
        .where(
          (task) =>
              _asInt(task['parentTaskId'] ?? task['ParentTaskId']) == null,
        )
        .toList();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openCreateTask() async {
    final result = await Navigator.pushNamed(
      context,
      '/tasks/new',
      arguments: {
        'projectId': _projectId,
        'projectName': _projectName,
        'statuses': _statuses,
        'priorities': _priorities,
        'members': _members,
        'epics': _epics,
      },
    );
    if (result == true) _loadBoard();
  }

  Future<void> _openDetail(dynamic task) async {
    final result = await Navigator.pushNamed(
      context,
      '/tasks/detail',
      arguments: {
        'task': task,
        'projectId': _projectId,
        'projectName': _projectName,
        'statuses': _statuses,
        'priorities': _priorities,
        'members': _members,
        'epics': _epics,
      },
    );
    if (result == true) _loadBoard();
  }

  Future<void> _moveTask(dynamic task, int statusId) async {
    final result = await TaskService.moveTask(_taskId(task), statusId);
    if (result['success'] == true) {
      await _loadBoard();
    } else {
      _snack(result['message'] ?? 'Could not move this task');
    }
  }

  Future<void> _selfAssign(dynamic task) async {
    final result = await TaskService.selfAssignTask(_taskId(task));
    if (result['success'] == true) {
      await _loadBoard();
    } else {
      _snack(result['message'] ?? 'Could not self-assign this task');
    }
  }

  Future<void> _unassign(dynamic task) async {
    final result = await TaskService.unassignTask(_taskId(task));
    if (result['success'] == true) {
      await _loadBoard();
    } else {
      _snack(result['message'] ?? 'Could not remove assignee');
    }
  }

  Future<void> _deleteTask(dynamic task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task'),
        content: Text(
          'Delete "${_taskTitle(task)}"? This will soft-delete the task.',
        ),
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
    final result = await TaskService.deleteTask(_taskId(task));
    if (result['success'] == true) {
      await _loadBoard();
    } else {
      _snack(result['message'] ?? 'Could not delete this task');
    }
  }

  Future<void> _showMoveSheet(dynamic task) async {
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
              final id = _statusId(status);
              return ListTile(
                leading: Icon(
                  id == _taskStatusId(task)
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: _primary,
                ),
                title: Text(_statusName(status)),
                onTap: () {
                  Navigator.pop(context);
                  _moveTask(task, id);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _showColumnDialog({dynamic status}) async {
    final controller = TextEditingController(
      text: status == null ? '' : _statusName(status),
    );
    final isEdit = status != null;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Rename column' : 'Create column'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 50,
          decoration: const InputDecoration(labelText: 'Column name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;
    final response = isEdit
        ? await TaskService.updateStatus(_statusId(status), result)
        : await TaskService.createStatus(result);
    if (response['success'] == true) {
      await _loadBoard();
    } else {
      _snack(response['message'] ?? 'Could not save column');
    }
  }

  Future<void> _deleteSelectedColumn() async {
    final status = _statuses.firstWhere(
      (item) => _statusId(item) == _selectedStatusId,
      orElse: () => null,
    );
    if (status == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete column'),
        content: Text(
          'Delete "${_statusName(status)}"? The column must be empty.',
        ),
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

    final response = await TaskService.deleteStatus(_statusId(status));
    if (response['success'] == true) {
      setState(() => _selectedStatusId = null);
      await _loadBoard();
    } else {
      _snack(response['message'] ?? 'Could not delete column');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_projectId == null) {
      return Scaffold(
        backgroundColor: _surface,
        appBar: AppBar(
          backgroundColor: _surface,
          elevation: 0,
          title: const Text(
            'TaskManage',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadProjects,
            ),
          ],
        ),
        body: _loadingProjects
            ? const Center(child: CircularProgressIndicator())
            : _projects.isEmpty
            ? const Center(child: Text('No projects found.'))
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Choose Project',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Select a project to open its TaskManage board.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ..._projects.map((project) {
                    final name = _text(
                      project['projectName'] ?? project['ProjectName'],
                      'Untitled project',
                    );
                    final status = _text(
                      project['statusName'] ?? project['StatusName'],
                      'Unknown',
                    );
                    final role = _text(
                      project['userRole'] ?? project['UserRole'],
                      'Member',
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _selectProject(project),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _softBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.view_kanban_outlined,
                                  color: _primary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$status • $role',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
      );
    }

    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: Text(
          _projectName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBoard),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add') _showColumnDialog();
              if (value == 'rename') {
                final status = _statuses.firstWhere(
                  (item) => _statusId(item) == _selectedStatusId,
                  orElse: () => null,
                );
                if (status != null) _showColumnDialog(status: status);
              }
              if (value == 'delete') _deleteSelectedColumn();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'add', child: Text('Add column')),
              PopupMenuItem(
                value: 'rename',
                child: Text('Rename selected column'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete selected column'),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBoard,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                children: [
                  const Text(
                    'TaskManage',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_tasks.length} tasks in this project',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _statuses.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final status = _statuses[index];
                        final id = _statusId(status);
                        final count = _tasks
                            .where((task) => _taskStatusId(task) == id)
                            .length;
                        final selected = _selectedStatusId == id;
                        return ChoiceChip(
                          selected: selected,
                          label: Text('${_statusName(status)}  $count'),
                          selectedColor: _primary,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.white
                                : const Color(0xFF666666),
                            fontWeight: FontWeight.bold,
                          ),
                          side: const BorderSide(color: _softBorder),
                          onSelected: (_) =>
                              setState(() => _selectedStatusId = id),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_visibleTasks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _softBorder),
                      ),
                      child: const Center(child: Text('No tasks yet')),
                    )
                  else
                    ..._visibleTasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TaskCard(
                          title: _taskTitle(task),
                          description: _taskDescription(task),
                          priority: _priorityName(task),
                          assignee: _assigneeName(task),
                          dueDate: _dateOnly(
                            task['dueDate'] ?? task['DueDate'],
                          ),
                          isSubTask:
                              _asInt(
                                task['parentTaskId'] ?? task['ParentTaskId'],
                              ) !=
                              null,
                          hasAssignee: _assigneeId(task) != null,
                          onTap: () => _openDetail(task),
                          onMove: () => _showMoveSheet(task),
                          onEdit: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/tasks/new',
                              arguments: {
                                'mode': 'edit',
                                'task': task,
                                'projectId': _projectId,
                                'projectName': _projectName,
                                'statuses': _statuses,
                                'priorities': _priorities,
                                'members': _members,
                                'epics': _epics,
                              },
                            );
                            if (result == true) _loadBoard();
                          },
                          onDelete: () => _deleteTask(task),
                          onSelfAssign: () => _selfAssign(task),
                          onUnassign: () => _unassign(task),
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateTask,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task),
        label: const Text('Task'),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String priority;
  final String assignee;
  final String dueDate;
  final bool isSubTask;
  final bool hasAssignee;
  final VoidCallback onTap;
  final VoidCallback onMove;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSelfAssign;
  final VoidCallback onUnassign;

  const _TaskCard({
    required this.title,
    required this.description,
    required this.priority,
    required this.assignee,
    required this.dueDate,
    required this.isSubTask,
    required this.hasAssignee,
    required this.onTap,
    required this.onMove,
    required this.onEdit,
    required this.onDelete,
    required this.onSelfAssign,
    required this.onUnassign,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _softBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
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
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Badge(
                        label: isSubTask ? 'SUB-TASK' : 'EPIC',
                        color: isSubTask ? const Color(0xFF4ECDC4) : _primary,
                      ),
                      if (priority.isNotEmpty)
                        _Badge(
                          label: priority.toUpperCase(),
                          color: Colors.orange,
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'move') onMove();
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'move', child: Text('Move status')),
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: _primary,
                ),
                const SizedBox(width: 6),
                Text(
                  dueDate,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (hasAssignee)
                  TextButton.icon(
                    onPressed: onUnassign,
                    icon: const Icon(Icons.person_remove_outlined, size: 16),
                    label: Text(assignee, overflow: TextOverflow.ellipsis),
                  )
                else
                  TextButton.icon(
                    onPressed: onSelfAssign,
                    icon: const Icon(Icons.person_add_alt_rounded, size: 16),
                    label: const Text('Claim'),
                  ),
              ],
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
