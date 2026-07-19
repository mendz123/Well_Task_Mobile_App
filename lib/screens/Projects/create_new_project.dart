import 'package:flutter/material.dart';
import '../../core/services/project_service.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _nameController = TextEditingController();
  final _repoUrlController = TextEditingController();
  final _descController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _repoUrlController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên dự án')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await ProjectService.createProject(
      name: name,
      description: _descController.text.trim(),
      repositoryUrl: _repoUrlController.text.trim().isEmpty ? null : _repoUrlController.text.trim(),
      startDate: _startDate?.toIso8601String(),
      endDate: _endDate?.toIso8601String(),
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Tạo dự án thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      appBar: const CreateProjectAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Project Name *',
                hintText: 'Project Name (e.g., Graduation Thesis)',
                controller: _nameController,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Repository URL (GitHub/GitLab)',
                hintText: 'https://github.com/username/repo',
                controller: _repoUrlController,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Project Goal / Description',
                hintText: 'Brief description of what you want to achieve...',
                maxLines: 4,
                controller: _descController,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DatePickerField(
                      label: 'Start Date',
                      valueText: _formatDate(_startDate),
                      onTap: () => _selectStartDate(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DatePickerField(
                      label: 'Deadline',
                      valueText: _formatDate(_endDate),
                      onTap: () => _selectEndDate(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: "Create Project",
                      onPressed: _handleCreate,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateProjectAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CreateProjectAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
      title: const Text(
        'Create New Project',
        style: TextStyle(
          color: Color(0xFF6C63FF),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final int maxLines;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.maxLines = 1,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF3F0FF).withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class DatePickerField extends StatelessWidget {
  final String label;
  final String valueText;
  final VoidCallback onTap;

  const DatePickerField({
    super.key,
    required this.label,
    required this.valueText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Color(0xFFB0B0B0), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    valueText,
                    style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
                  ),
                ),
                const Icon(Icons.calendar_month, color: Color(0xFF1A1A1A), size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFF6C63FF).withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.rocket_launch_outlined, size: 24),
          ],
        ),
      ),
    );
  }
}
