import 'package:flutter/material.dart';
import '../../core/services/project_service.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  int? projectId;
  Map<String, dynamic>? _projectData;
  bool _isLoading = true;
  bool _isLeader = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (projectId == null) {
      projectId = ModalRoute.of(context)?.settings.arguments as int?;
      if (projectId != null) {
        _fetchProjectDetails();
      }
    }
  }

  Future<void> _fetchProjectDetails() async {
    setState(() => _isLoading = true);
    final data = await ProjectService.getProjectDetails(projectId!);
    if (mounted) {
      setState(() {
        _projectData = data;
        _isLeader = data['project']?['userRole'] == 'TeamLeader';
        _isLoading = false;
      });
    }
  }

  void _showUpdateDialog() {
    final project = _projectData?['project'];
    final nameController = TextEditingController(text: project?['projectName']);
    final descController = TextEditingController(text: project?['description']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên dự án'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mô tả'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final res = await ProjectService.updateProject(projectId!, {
                'projectName': nameController.text,
                'description': descController.text,
                'projectStatusId': project?['projectStatusId'], // Giữ nguyên status
                'startDate': project?['startDate'],
                'endDate': project?['endDate'],
              });
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
                _fetchProjectDetails();
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showInviteDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mời thành viên'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            hintText: 'Nhập email người nhận',
            labelText: 'Email',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty) {
                final res = await ProjectService.inviteMember(projectId!, emailController.text);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
                }
              }
            },
            child: const Text('Gửi Mail'),
          ),
        ],
      ),
    );
  }

  void _handleLeave() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rời nhóm'),
        content: const Text('Bạn có chắc muốn rời nhóm? Yêu cầu sẽ được gửi đến Leader và bạn chỉ có thể rời khi Leader nhấn Accept.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Không')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Xác nhận rời', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      final res = await ProjectService.leaveProject(projectId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
        _fetchProjectDetails();
      }
    }
  }

  void _handleLeaveRequestAction(String requestId, bool approve) async {
    final res = approve 
      ? await ProjectService.approveLeave(requestId)
      : await ProjectService.rejectLeave(requestId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
      _fetchProjectDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final project = _projectData?['project'];
    final members = _projectData?['members'] as List<dynamic>? ?? [];
    final leaveRequests = _projectData?['leaveRequests'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FF),
      appBar: AppBar(
        title: Text(project?['projectName'] ?? 'Chi tiết dự án'),
        actions: [
          if (_isLeader)
            IconButton(icon: const Icon(Icons.person_add_alt), onPressed: _showInviteDialog),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLeader)
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Cập nhật thông tin Project'),
                        onTap: () {
                          Navigator.pop(context);
                          _showUpdateDialog();
                        },
                      ),
                    if (!_isLeader || members.length > 1) // Leader có thể rời nếu có người khác hoặc theo logic BE
                      ListTile(
                        leading: const Icon(Icons.exit_to_app, color: Colors.red),
                        title: const Text('Rời nhóm', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          Navigator.pop(context);
                          _handleLeave();
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin dự án
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Trạng thái:', style: TextStyle(color: Colors.grey)),
                          Text(project?['statusName'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(project?['description'] ?? 'Không có mô tả', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),

            // Quản lý yêu cầu rời nhóm (Chỉ cho Leader)
            if (_isLeader && leaveRequests.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Yêu cầu rời nhóm chờ duyệt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
              ),
              const SizedBox(height: 8),
              ...leaveRequests.map((req) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade100)),
                child: ListTile(
                  title: Text(req['fullName'] ?? req['email']),
                  subtitle: Text(req['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => _handleLeaveRequestAction(req['requestId'], true)),
                      IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => _handleLeaveRequestAction(req['requestId'], false)),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 16),
            ],

            // Danh sách thành viên
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Thành viên trong nhóm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            ...members.map((m) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: CircleAvatar(
                backgroundImage: m['avatarUrl'] != null ? NetworkImage(m['avatarUrl']) : null,
                child: m['avatarUrl'] == null ? const Icon(Icons.person) : null,
              ),
              title: Text(m['fullName'] ?? m['email']),
              subtitle: Text(m['roleName']),
            )),
          ],
        ),
      ),
    );
  }
}
