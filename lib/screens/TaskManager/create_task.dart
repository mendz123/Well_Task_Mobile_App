import 'package:flutter/material.dart';

class CreateTaskScreen extends StatelessWidget {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      appBar: const CreateTaskAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomTextField(
              label: 'Task Name',
              hintText: 'Design Logo',
              isLarge: true,
            ),
            const SizedBox(height: 24),
            const ProjectDropdown(
              label: 'PROJECT',
              projectName: 'Graduation Thesis',
            ),
            const SizedBox(height: 24),
            const StatusSelector(
              label: 'STATUS',
              statuses: ['Backlog', 'In Progress', 'Review', 'Completed'],
              activeIndex: 1,
            ),
            const SizedBox(height: 24),
            const PrioritySelector(
              label: 'PRIORITY',
              activeIndex: 0,
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Expanded(
                  child: AssigneePicker(label: 'ASSIGNEE'),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: DeadlinePicker(label: 'Deadline', date: '24 Th10, 2023'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const CustomTextField(
              label: 'DESCRIPTION',
              hintText: 'Add a detailed description for this task...',
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            const SubtaskSection(
              label: 'SUBTASKS',
              subtasks: [
                {'title': 'Competitor Research', 'isDone': false},
                {'title': 'Create Moodboard', 'isDone': true},
              ],
            ),
            const SizedBox(height: 24),
            const SkillsPicker(
              label: 'REQUIRED SKILLS',
              skills: ['UI Design', 'Figma'],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class CreateTaskAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CreateTaskAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)), onPressed: () { Navigator.pop(context); }),
      title: const Text(
        'Create New Task',
        style: TextStyle(
          color: Color(0xFF1A1A1A),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Center(
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF666666),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isLarge;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.isLarge = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: label),
        TextField(
          maxLines: maxLines,
          style: TextStyle(
            fontSize: isLarge ? 18 : 14,
            fontWeight: isLarge ? FontWeight.bold : FontWeight.normal,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF3F0FF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF3F0FF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class ProjectDropdown extends StatelessWidget {
  final String label;
  final String projectName;

  const ProjectDropdown({super.key, required this.label, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: label),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF3F0FF)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder_open_rounded, color: Color(0xFF4ECDC4), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  projectName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFB0B0B0)),
            ],
          ),
        ),
      ],
    );
  }
}

class StatusSelector extends StatelessWidget {
  final String label;
  final List<String> statuses;
  final int activeIndex;

  const StatusSelector({
    super.key,
    required this.label,
    required this.statuses,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: label),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(statuses.length, (index) {
              final bool isActive = index == activeIndex;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF6C63FF) : const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statuses[index],
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFF666666),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class PrioritySelector extends StatelessWidget {
  final String label;
  final int activeIndex;

  const PrioritySelector({super.key, required this.label, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {'label': 'High', 'color': const Color(0xFFFF6B6B), 'bg': const Color(0xFFFFEBEB)},
      {'label': 'Medium', 'color': const Color(0xFFFFB347), 'bg': const Color(0xFFFFF4E6)},
      {'label': 'Low', 'color': const Color(0xFFB0B0B0), 'bg': const Color(0xFFF3F0FF)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: label),
        Row(
          children: List.generate(options.length, (index) {
            final bool isActive = index == activeIndex;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == options.length - 1 ? 0 : 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: options[index]['bg'],
                  borderRadius: BorderRadius.circular(10),
                  border: isActive ? Border.all(color: options[index]['color'], width: 1.5) : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: options[index]['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      options[index]['label'],
                      style: TextStyle(
                        color: options[index]['color'],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class AssigneePicker extends StatelessWidget {
  final String label;
  const AssigneePicker({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: label),
        Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=32'),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0), style: BorderStyle.solid),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 16, color: Color(0xFFB0B0B0)),
            ),
          ],
        ),
      ],
    );
  }
}

class DeadlinePicker extends StatelessWidget {
  final String label;
  final String date;

  const DeadlinePicker({super.key, required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF3F0FF)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF6C63FF)),
              const SizedBox(width: 8),
              Text(
                date,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SubtaskSection extends StatelessWidget {
  final String label;
  final List<Map<String, dynamic>> subtasks;

  const SubtaskSection({super.key, required this.label, required this.subtasks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: label),
        ...subtasks.map((task) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF3F0FF)),
          ),
          child: Row(
            children: [
              Icon(
                task['isDone'] ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: task['isDone'] ? const Color(0xFF6C63FF) : const Color(0xFFB0B0B0),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task['title'],
                  style: TextStyle(
                    fontSize: 14,
                    color: task['isDone'] ? const Color(0xFFB0B0B0) : const Color(0xFF1A1A1A),
                    decoration: task['isDone'] ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              const Icon(Icons.close, size: 16, color: Color(0xFFB0B0B0)),
            ],
          ),
        )),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add SUBTASKS'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6C63FF),
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

class SkillsPicker extends StatelessWidget {
  final String label;
  final List<String> skills;

  const SkillsPicker({super.key, required this.label, required this.skills});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: label),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...skills.map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    skill,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF666666)),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.close, size: 12, color: Color(0xFFB0B0B0)),
                ],
              ),
            )),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 16, color: Color(0xFFB0B0B0)),
            ),
          ],
        ),
      ],
    );
  }
}
