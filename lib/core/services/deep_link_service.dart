import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'project_service.dart';
import 'auth_service.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;
  String? _pendingToken;
  int? _pendingManageProjectId;

  void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _appLinks = AppLinks();

    // Lắng nghe link khi app đang chạy hoặc từ background
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingLink(uri);
    });

    // Kiểm tra nếu app được mở từ link (cold start)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleIncomingLink(uri);
      }
    });
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  void checkPendingInvitation() {
    if (_pendingToken != null) {
      final token = _pendingToken!;
      _pendingToken = null;
      _processInvitation(token);
    } else if (_pendingManageProjectId != null) {
      final projectId = _pendingManageProjectId!;
      _pendingManageProjectId = null;
      _processLeaveRequest(projectId);
    }
  }

  void _handleIncomingLink(Uri uri) {
    // Cấu trúc link từ BE: http://localhost:5117/Projects/Join?token=GUID
    if (uri.path.contains('/Projects/Join')) {
      final token = uri.queryParameters['token'];
      if (token != null) {
        _processInvitation(token);
      }
    } else if (uri.path.contains('/Projects/Manage')) {
      final segments = uri.pathSegments;
      if (segments.length >= 3) {
        final projectIdStr = segments[2];
        final projectId = int.tryParse(projectIdStr);
        if (projectId != null) {
          _processLeaveRequest(projectId);
        }
      }
    }
  }

  void _processInvitation(String token) async {
    // Đợi 1 chút để đảm bảo Navigator đã sẵn sàng
    int retryCount = 0;
    while ((_navigatorKey?.currentContext == null || _navigatorKey?.currentState == null) && retryCount < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      retryCount++;
    }

    final context = _navigatorKey?.currentState?.overlay?.context ?? _navigatorKey?.currentContext;
    if (context == null) return;

    // Kiểm tra trạng thái đăng nhập
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!context.mounted) return;
    if (!isLoggedIn) {
      _pendingToken = token;
      // Chuyển hướng tới login
      if (_navigatorKey?.currentState != null) {
        _navigatorKey!.currentState!.pushNamedAndRemoveUntil('/login', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để tham gia dự án')),
        );
      }
      return;
    }

    // Hiển thị dialog xử lý
    _showJoiningDialog(context, token);
  }

  void _processLeaveRequest(int projectId) async {
    // Đợi 1 chút để đảm bảo Navigator đã sẵn sàng
    int retryCount = 0;
    while ((_navigatorKey?.currentContext == null || _navigatorKey?.currentState == null) && retryCount < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      retryCount++;
    }

    final context = _navigatorKey?.currentState?.overlay?.context ?? _navigatorKey?.currentContext;
    if (context == null) return;

    // Kiểm tra trạng thái đăng nhập
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!context.mounted) return;
    if (!isLoggedIn) {
      _pendingManageProjectId = projectId;
      // Chuyển hướng tới login
      if (_navigatorKey?.currentState != null) {
        _navigatorKey!.currentState!.pushNamedAndRemoveUntil('/login', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để duyệt yêu cầu rời nhóm')),
        );
      }
      return;
    }

    // Đã đăng nhập, điều hướng trực tiếp tới trang chi tiết dự án
    if (_navigatorKey?.currentState != null) {
      _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_navigatorKey?.currentState != null) {
          _navigatorKey!.currentState!.pushNamed(
            '/projects/detail',
            arguments: projectId,
          );
        }
      });
    }
  }

  void _showJoiningDialog(BuildContext context, String token) async {
    BuildContext? dialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogContext = ctx;
        return const AlertDialog(
          title: Text('Lời mời tham gia dự án'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang xác thực và gia nhập dự án...'),
            ],
          ),
        );
      },
    );

    try {
      final res = await ProjectService.acceptInvitation(token);
      
      final currentDialogContext = dialogContext;
      if (currentDialogContext != null && currentDialogContext.mounted) {
        if (Navigator.canPop(currentDialogContext)) {
          Navigator.of(currentDialogContext).pop();
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final postFrameContext = dialogContext;
          if (postFrameContext != null && postFrameContext.mounted) {
            if (Navigator.canPop(postFrameContext)) {
              Navigator.of(postFrameContext).pop();
            }
          }
        });
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? '')),
      );

      if (res['success'] == true) {
        // Điều hướng về trang dự án
        _navigatorKey?.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      final currentDialogContext = dialogContext;
      if (currentDialogContext != null && currentDialogContext.mounted) {
        if (Navigator.canPop(currentDialogContext)) {
          Navigator.of(currentDialogContext).pop();
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final postFrameContext = dialogContext;
          if (postFrameContext != null && postFrameContext.mounted) {
            if (Navigator.canPop(postFrameContext)) {
              Navigator.of(postFrameContext).pop();
            }
          }
        });
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi hệ thống: ${e.toString()}')),
      );
    }
  }
}
