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

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _estimateController = TextEditingController();

  bool _initialized = false;
  bool _loadingLookups = false;
  bool _saving = false;
  bool _isEdit = false;
  int? _projectId;
  Map<String, dynamic>? _task;
  List<dynamic> _statuses = [];
  List<dynamic> _priorities = [];
  List<dynamic> _members = [];
  List<dynamic> _epics = [];
  int? _statusId;
  int? _priorityId;
  int? _assigneeId;
  int? _parentTaskId;
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimateController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _projectId = _asInt(args['projectId']);
      _isEdit = args['mode'] == 'edit';
      _task = args['task'] is Map<String, dynamic>
          ? args['task'] as Map<String, dynamic>
          : null;
      _statuses = args['statuses'] as List<dynamic>? ?? [];
      _priorities = args['priorities'] as List<dynamic>? ?? [];
      _members = args['members'] as List<dynamic>? ?? [];
      _epics = args['epics'] as List<dynamic>? ?? [];
    }

    _hydrateTask();
    if (_projectId != null && (_statuses.isEmpty || _priorities.isEmpty)) {
      _loadLookups();
    }
  }

  void _hydrateTask() {
    final task = _task;
    if (task == null) return;

    _titleController.text = _text(task['title'] ?? task['Title']);
    _descriptionController.text = _text(
      task['description'] ?? task['Description'],
    );
    _estimateController.text = _text(
      task['estimateHours'] ?? task['EstimateHours'],
    );
    _statusId = _asInt(task['taskStatusId'] ?? task['TaskStatusId']);
    _priorityId = _asInt(task['priorityId'] ?? task['PriorityId']);
    _assigneeId = _asInt(task['assigneeId'] ?? task['AssigneeId']);
    _parentTaskId = _asInt(task['parentTaskId'] ?? task['ParentTaskId']);

    final due = task['dueDate'] ?? task['DueDate'];
    if (due != null) _dueDate = DateTime.tryParse(due.toString());
  }

  Future<void> _loadLookups() async {
    setState(() => _loadingLookups = true);
    final lookups = await TaskService.getLookups(_projectId!);
    final tasks = await TaskService.getTasksByProject(_projectId!);
    if (!mounted) return;
    setState(() {
      _statuses = lookups['statuses'] as List<dynamic>? ?? [];
      _priorities = lookups['priorities'] as List<dynamic>? ?? [];
      _members = lookups['members'] as List<dynamic>? ?? [];
      _epics = tasks
          .where(
            (task) =>
        _asInt(task['parentTaskId'] ?? task['ParentTaskId']) == null,
      )
          .toList();
      _statusId ??= _statuses.isNotEmpty ? _statusIdOf(_statuses.first) : null;
      _priorityId ??= _priorities.isNotEmpty
          ? _priorityIdOf(_priorities.first)
          : null;
      _loadingLookups = false;
    });
  }

  int _statusIdOf(dynamic item) =>
      _asInt(item['taskStatusId'] ?? item['TaskStatusId']) ?? 0;
  int _priorityIdOf(dynamic item) =>
      _asInt(item['priorityId'] ?? item['PriorityId']) ?? 0;
  int _memberIdOf(dynamic item) =>
      _asInt(item['userId'] ?? item['UserId']) ?? 0;
  int _taskIdOf(dynamic item) => _asInt(item['taskId'] ?? item['TaskId']) ?? 0;

  String _statusName(dynamic item) =>
      _text(item['statusName'] ?? item['StatusName'], 'Status');
  String _priorityName(dynamic item) =>
      _text(item['priorityName'] ?? item['PriorityName'], 'Priority');
  String _memberName(dynamic item) => _text(
    item['fullName'] ?? item['FullName'] ?? item['email'] ?? item['Email'],
    'Member',
  );
  String _epicTitle(dynamic item) =>
      _text(item['title'] ?? item['Title'], 'Untitled epic');

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String? _validateDueDate() {
    if (_dueDate == null) return 'Due date is required.';
    final picked = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);
    if (picked.isBefore(_today)) return 'Due date cannot be in the past.';
    return null;
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate == null || _dueDate!.isBefore(_today)
          ? _today
          : _dueDate!,
      firstDate: _today,
      lastDate: DateTime(_today.year + 10),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final dueError = _validateDueDate();
    if (dueError != null) {
      _showMessage(dueError);
      return;
    }

    if (_statusId == null || _priorityId == null || _projectId == null) {
      _showMessage('Status and priority are required.');
      return;
    }

    setState(() => _saving = true);
    final estimateText = _estimateController.text.trim();
    final dueIso = DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
    ).toIso8601String();
    final payload = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'parentTaskId': _parentTaskId,
      'taskStatusId': _statusId,
      'priorityId': _priorityId,
      'dueDate': dueIso,
      'estimateHours': estimateText.isEmpty
          ? null
          : double.tryParse(estimateText),
    };

    Map<String, dynamic> result;
    if (_isEdit && _task != null) {
      result = await TaskService.updateTask(_taskIdOf(_task), {
        ...payload,
        'clearParentTask': _parentTaskId == null,
        'clearDueDate': false,
      });

      if (result['success'] == true) {
        final currentAssigneeId = _asInt(
          _task?['assigneeId'] ?? _task?['AssigneeId'],
        );
        if (currentAssigneeId != _assigneeId) {
          if (_assigneeId == null) {
            result = await TaskService.unassignTask(_taskIdOf(_task));
          } else {
            result = await TaskService.assignTask(
              _taskIdOf(_task),
              _assigneeId!,
            );
          }
        }
      }
    } else {
      result = await TaskService.createTask({
        ...payload,
        'projectId': _projectId,
        'assigneeId': _assigneeId,
      });
    }

    if (!mounted) return;
    setState(() => _saving = false);
    if (result['success'] == true) {
      Navigator.pop(context, true);
    } else {
      _showMessage(result['message'] ?? 'Could not save task.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: Text(
          _isEdit ? 'Update Task' : 'Create Task',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(backgroundColor: _primary),
              child: Text(_saving ? 'Saving...' : 'Save'),
            ),
          ),
        ],
      ),
      body: _loadingLookups
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Field(
              label: 'Title',
              child: TextFormField(
                controller: _titleController,
                maxLength: 200,
                decoration: const InputDecoration(hintText: 'Task title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required.';
                  }
                  return null;
                },
              ),
            ),
            _Field(
              label: 'Description',
              child: TextFormField(
                controller: _descriptionController,
                maxLength: 2000,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Task description',
                ),
              ),
            ),
            _Dropdown<int?>(
              label: 'Task type',
              value: _parentTaskId,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Epic / Parent Task'),
                ),
                ..._epics
                    .where(
                      (epic) =>
                  _task == null ||
                      _taskIdOf(epic) != _taskIdOf(_task),
                )
                    .map(
                      (epic) => DropdownMenuItem<int?>(
                    value: _taskIdOf(epic),
                    child: Text('Sub-task of: ${_epicTitle(epic)}'),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _parentTaskId = value),
            ),
            _Dropdown<int>(
              label: 'Status',
              value: _statusId,
              items: _statuses
                  .map(
                    (status) => DropdownMenuItem<int>(
                  value: _statusIdOf(status),
                  child: Text(_statusName(status)),
                ),
              )
                  .toList(),
              onChanged: (value) => setState(() => _statusId = value),
            ),
            _Dropdown<int>(
              label: 'Priority',
              value: _priorityId,
              items: _priorities
                  .map(
                    (priority) => DropdownMenuItem<int>(
                  value: _priorityIdOf(priority),
                  child: Text(_priorityName(priority)),
                ),
              )
                  .toList(),
              onChanged: (value) => setState(() => _priorityId = value),
            ),
            _Dropdown<int?>(
              label: 'Assignee',
              value: _assigneeId,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Unassigned'),
                ),
                ..._members.map(
                      (member) => DropdownMenuItem<int?>(
                    value: _memberIdOf(member),
                    child: Text(_memberName(member)),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _assigneeId = value),
            ),
            _Field(
              label: 'Due date',
              child: InkWell(
                onTap: _pickDueDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  child: Text(
                    _dueDate == null
                        ? 'Select due date'
                        : _dueDate!.toIso8601String().split('T').first,
                  ),
                ),
              ),
            ),
            _Field(
              label: 'Estimate hours',
              child: TextFormField(
                controller: _estimateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '0'),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return null;
                  }
                  final number = double.tryParse(text);
                  if (number == null) {
                    return 'Estimate hours must be a number.';
                  }
                  if (number < 0) {
                    return 'Estimate hours cannot be negative.';
                  }
                  if (number > 999.99) {
                    return 'Estimate hours must be less than 1000.';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;

  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _softBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _softBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _primary, width: 1.5),
                ),
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasMatch = value == null || items.any((item) => item.value == value);
    final safeValue = hasMatch ? value : (items.isNotEmpty ? items.first.value : null);

    return _Field(
      label: label,
      child: DropdownButtonFormField<T>(
        initialValue: safeValue,
        isExpanded: true,
        decoration: const InputDecoration(),
        items: items,
        onChanged: onChanged,
        validator: (val) {
          if (label == 'Status' && val == null) {
            return 'Status is required.';
          }
          if (label == 'Priority' && val == null) {
            return 'Priority is required.';
          }
          return null;
        },
      ),
    );
  }
}
