import 'dart:convert';
import '../api_client.dart';
import '../constants.dart';

class ProjectService {
  /// Lấy tất cả dự án người dùng tham gia (Dữ liệu thật từ BE)
  /// BE trả về: List<ProjectResponse> { ProjectId, ProjectName, StatusName, UserRole, ... }
  static Future<List<dynamic>> getAllProjects() async {
    try {
      final response = await ApiClient.get(ApiConstants.projects);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching projects: $e');
      return [];
    }
  }

  /// Lấy chi tiết dự án (Bao gồm danh sách thành viên và yêu cầu rời nhóm cho Leader)
  static Future<Map<String, dynamic>> getProjectDetails(int id) async {
    try {
      final response = await ApiClient.get(ApiConstants.projectDetail(id));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print('Error fetching project details: $e');
      return {};
    }
  }

  /// Tạo dự án mới (Người tạo tự động thành TeamLeader theo logic BE)
  static Future<Map<String, dynamic>> createProject({
    required String name,
    required String description,
    String? repositoryUrl,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await ApiClient.post(ApiConstants.projects, {
        'projectName': name,
        'description': description,
        'repositoryUrl': repositoryUrl,
        'startDate': startDate,
        'endDate': endDate,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final err = jsonDecode(response.body);
        return {'success': false, 'message': err['message'] ?? 'Failed to create project'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Cập nhật thông tin dự án (Chỉ dành cho TeamLeader)
  static Future<Map<String, dynamic>> updateProject(int id, Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.put(ApiConstants.projectDetail(id), data);
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Cập nhật thành công'};
      }
      final err = jsonDecode(response.body);
      return {'success': false, 'message': err['message'] ?? 'Update failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Mời user vào dự án (BE sẽ gửi mail mời)
  static Future<Map<String, dynamic>> inviteMember(int projectId, String email) async {
    try {
      final response = await ApiClient.post(ApiConstants.inviteMember(projectId), {
        'email': email,
      });
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đã gửi mail mời đến $email'};
      }
      final err = jsonDecode(response.body);
      return {'success': false, 'message': err['message'] ?? 'Failed to send invitation'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Member rời dự án (Gửi mail thông báo cho Leader, chờ duyệt)
  static Future<Map<String, dynamic>> leaveProject(int projectId) async {
    try {
      final response = await ApiClient.post(ApiConstants.leaveProject(projectId), {});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Yêu cầu rời nhóm đã được gửi'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to send leave request'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  
  /// Leader duyệt yêu cầu rời nhóm
  static Future<Map<String, dynamic>> approveLeave(String requestId) async {
    try {
      final response = await ApiClient.post(ApiConstants.approveLeaveRequest(requestId), {});
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đã đồng ý cho thành viên rời nhóm'};
      }
      return {'success': false, 'message': 'Operation failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Leader từ chối yêu cầu rời nhóm
  static Future<Map<String, dynamic>> rejectLeave(String requestId) async {
    try {
      final response = await ApiClient.post(ApiConstants.rejectLeaveRequest(requestId), {});
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đã từ chối yêu cầu rời nhóm'};
      }
      return {'success': false, 'message': 'Operation failed'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Chấp nhận lời mời tham gia dự án bằng Token (Xử lý từ Deep Link)
  static Future<Map<String, dynamic>> acceptInvitation(String token) async {
    try {
      final response = await ApiClient.post('${ApiConstants.baseUrl}/projects/invitations/$token/accept', {});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Gia nhập dự án thành công'};
      }
      return {'success': false, 'message': data['message'] ?? 'Mã mời không hợp lệ hoặc đã hết hạn'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
