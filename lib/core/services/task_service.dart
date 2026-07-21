import 'dart:convert';
import '../api_client.dart';
import '../constants.dart';

class TaskService {
  static Map<String, dynamic> _decodeMap(String body) {
    if (body.trim().isEmpty) return {};
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : {};
  }

  static String _messageFromBody(String body, String fallback) {
    try {
      final data = _decodeMap(body);
      return data['message']?.toString() ?? fallback;
    } catch (_) {
      return fallback;
    }
  }

  static Future<List<dynamic>> getTasksByProject(int projectId) async {
    try {
      final response = await ApiClient.get(
        ApiConstants.tasksByProject(projectId),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : [];
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getLookups(int projectId) async {
    try {
      final response = await ApiClient.get(ApiConstants.taskLookups(projectId));
      if (response.statusCode == 200) {
        return _decodeMap(response.body);
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> createTask(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await ApiClient.post(ApiConstants.tasks, data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': _decodeMap(response.body)};
      }
      return {
        'success': false,
        'message': _messageFromBody(response.body, 'Failed to create task'),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateTask(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await ApiClient.patch(ApiConstants.taskDetail(id), data);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'data': response.body.isNotEmpty ? _decodeMap(response.body) : null,
        };
      }
      return {
        'success': false,
        'message': _messageFromBody(response.body, 'Failed to update task'),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteTask(int id) async {
    try {
      final response = await ApiClient.delete(ApiConstants.taskDetail(id));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      }
      return {
        'success': false,
        'message': _messageFromBody(response.body, 'Failed to delete task'),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> moveTask(int id, int statusId) {
    return updateTask(id, {'taskStatusId': statusId});
  }

  static Future<Map<String, dynamic>> assignTask(int id, int userId) async {
    try {
      final response = await ApiClient.post(ApiConstants.assignTask(id), {
        'userId': userId,
      });
      if (response.statusCode == 200) {
        return {'success': true};
      }
      return {
        'success': false,
        'message': _messageFromBody(response.body, 'Failed to assign task'),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> unassignTask(int id) async {
    try {
      final response = await ApiClient.delete(ApiConstants.taskAssignee(id));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      }
      return {
        'success': false,
        'message': _messageFromBody(response.body, 'Failed to remove assignee'),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> selfAssignTask(int id) async {
    try {
      final response = await ApiClient.post(
        ApiConstants.selfAssignTask(id),
        {},
      );
      if (response.statusCode == 200) {
        return {'success': true};
      }
      return {
        'success': false,
        'message': _messageFromBody(
          response.body,
          'Failed to self-assign task',
        ),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createStatus(String name) async {
    try {
      final response = await ApiClient.post(ApiConstants.taskStatuses, {
        'statusName': name,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': _decodeMap(response.body)};
      }
      return {
        'success': false,
        'message': _messageFromBody(response.body, 'Failed to create column'),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateStatus(int id, String name) async {
    try {
      final response = await ApiClient.put(ApiConstants.taskStatus(id), {
        'statusName': name,
      });
      if (response.statusCode == 200) {
        return {'success': true, 'data': _decodeMap(response.body)};
      }
      return {
        'success': false,
        'message': _messageFromBody(response.body, 'Failed to update column'),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteStatus(int id) async {
    try {
      final response = await ApiClient.delete(ApiConstants.taskStatus(id));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      }
      return {
        'success': false,
        'message': _messageFromBody(response.body, 'Failed to delete column'),
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
