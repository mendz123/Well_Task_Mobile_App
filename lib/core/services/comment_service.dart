import 'dart:convert';
import '../api_client.dart';
import '../constants.dart';

class CommentService {
  static Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) return {};
    final d = jsonDecode(body);
    return d is Map<String, dynamic> ? d : {};
  }

  /// Lấy danh sách comment của một task (qua OData)
  static Future<List<Map<String, dynamic>>> getByTask(int taskId) async {
    try {
      final response = await ApiClient.get(ApiConstants.commentsByTask(taskId));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> values = data['value'] ?? [];
        return values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Tạo comment mới (Backend tự lấy userId từ JWT)
  static Future<Map<String, dynamic>> createComment({
    required int taskId,
    required String content,
  }) async {
    try {
      final response = await ApiClient.post(ApiConstants.comments, {
        'taskId': taskId,
        'content': content,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': _decode(response.body)};
      }
      String msg = 'Failed to post comment';
      try {
        final err = jsonDecode(response.body);
        msg = err['message']?.toString() ?? msg;
      } catch (_) {}
      return {'success': false, 'message': msg};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Xóa comment (chỉ author hoặc leader mới được)
  static Future<Map<String, dynamic>> deleteComment(int commentId) async {
    try {
      final response = await ApiClient.delete(ApiConstants.commentDetail(commentId));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      }
      return {'success': false, 'message': 'Failed to delete comment'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
