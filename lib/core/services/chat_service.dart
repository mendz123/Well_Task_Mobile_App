import 'package:signalr_netcore/signalr_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

/// Model cho một tin nhắn chat
class ChatMessage {
  final int messageId;
  final int projectId;
  final int senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;

  ChatMessage({
    required this.messageId,
    required this.projectId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'] ?? 0,
      projectId: json['projectId'] ?? 0,
      senderId: json['senderId'] ?? 0,
      senderName: json['senderName'] ?? 'Unknown',
      content: json['content'] ?? '',
      sentAt: json['sentAt'] != null
          ? DateTime.tryParse(json['sentAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Service xử lý SignalR realtime chat
class ChatService {
  final String _hubUrl = ApiConstants.hubUrl;

  HubConnection? _connection;

  // Callbacks mà UI sẽ đăng ký để nhận sự kiện
  Function(ChatMessage)? onMessageReceived;
  Function(String senderName)? onUserTyping;
  Function(String message)? onError;
  Function()? onConnected;
  Function()? onDisconnected;

  bool get isConnected =>
      _connection?.state == HubConnectionState.Connected;

  Future<void> connect() async {
    if (isConnected) return;

    final token = await _getToken();

    _connection = HubConnectionBuilder()
        .withUrl(
          _hubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: token != null ? () async => token : null,
            skipNegotiation: true,
            transport: HttpTransportType.WebSockets,
          ),
        )
        .withAutomaticReconnect()
        .build();

    // Đăng ký nhận tin nhắn mới
    _connection!.on('ReceiveMessage', (args) {
      if (args == null || args.isEmpty) return;
      try {
        final data = args[0] as Map<String, dynamic>;
        final msg = ChatMessage.fromJson(data);
        onMessageReceived?.call(msg);
      } catch (e) {
        onError?.call('Failed to parse message: $e');
      }
    });

    // Đăng ký nhận typing indicator
    _connection!.on('UserTyping', (args) {
      if (args == null || args.isEmpty) return;
      try {
        final data = args[0] as Map<String, dynamic>;
        final senderName = data['senderName']?.toString() ?? 'Someone';
        onUserTyping?.call(senderName);
      } catch (_) {}
    });

    // Đăng ký nhận lỗi từ server
    _connection!.on('Error', (args) {
      final msg = args?.isNotEmpty == true ? args![0]?.toString() : 'Unknown error';
      onError?.call(msg ?? 'Unknown error');
    });

    _connection!.onclose(({Exception? error}) {
      onDisconnected?.call();
    });

    _connection!.onreconnected(({String? connectionId}) {
      onConnected?.call();
    });

    try {
      await _connection!.start();
      onConnected?.call();
    } catch (e) {
      onError?.call('Connection failed: $e');
    }
  }

  Future<void> joinRoom(int projectId, {int senderId = 0, String displayName = ''}) async {
    if (!isConnected) return;
    try {
      await _connection!.invoke('JoinProjectRoom', args: [projectId, senderId, displayName]);
    } catch (e) {
      onError?.call('JoinRoom error: $e');
    }
  }

  Future<void> leaveRoom(int projectId) async {
    if (!isConnected) return;
    try {
      await _connection!.invoke('LeaveProjectRoom', args: [projectId]);
    } catch (_) {}
  }

  Future<void> sendMessage(int projectId, String content, {int senderId = 0, String displayName = ''}) async {
    if (!isConnected) {
      onError?.call('Not connected to chat server');
      return;
    }
    try {
      await _connection!.invoke('SendMessage', args: [projectId, content, senderId, displayName]);
    } catch (e) {
      onError?.call('Send failed: $e');
    }
  }

  Future<void> sendTyping(int projectId, {int senderId = 0, String displayName = ''}) async {
    if (!isConnected) return;
    try {
      await _connection!.invoke('Typing', args: [projectId, senderId, displayName]);
    } catch (_) {}
  }

  Future<void> disconnect() async {
    try {
      await _connection?.stop();
    } catch (_) {}
    _connection = null;
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('AccessToken');
    } catch (_) {
      return null;
    }
  }
}
