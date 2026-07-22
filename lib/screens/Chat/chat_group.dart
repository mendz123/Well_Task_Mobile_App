import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/project_service.dart';

// ─── Screen 1: Project List (chọn nhóm để chat) ─────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      final raw = await ProjectService.getAllProjects();
      setState(() {
        _projects = raw
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Group Chats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6C63FF)),
            onPressed: _loadProjects,
          ),
        ],
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            )
          : _projects.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              onRefresh: _loadProjects,
              color: const Color(0xFF6C63FF),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _projects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final project = _projects[index];
                  final id = project['projectId'] ?? project['id'] ?? 0;
                  final name =
                      project['projectName'] ??
                      project['name'] ??
                      'Unknown Project';
                  return _ProjectChatCard(
                    projectId: id as int,
                    projectName: name.toString(),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          const Text(
            'No projects found.',
            style: TextStyle(color: Color(0xFF999999), fontSize: 15),
          ),
          const SizedBox(height: 6),
          const Text(
            'Join or create a project to start chatting.',
            style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProjectChatCard extends StatelessWidget {
  final int projectId;
  final String projectName;
  const _ProjectChatCard({required this.projectId, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ChatRoomScreen(projectId: projectId, projectName: projectName),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9C8FFF)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to open chat',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}

// ─── Screen 2: Chat Room (realtime) ──────────────────────────────────────────

class ChatRoomScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const ChatRoomScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];

  int _myUserId = 0;
  String _myDisplayName = '';
  bool _isConnecting = true;
  bool _isConnected = false;
  String? _typingUser;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    _myUserId = await AuthService.getUserId();
    _myDisplayName = await AuthService.getUserName();
    _setupChatService();
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final response = await ApiClient.get(
        ApiConstants.chatHistory(widget.projectId),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.addAll(
              data.map(
                (e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)),
              ),
            );
          });
          _scrollToBottom();
        }
      }
    } catch (_) {}
  }

  void _setupChatService() {
    _chatService.onMessageReceived = (msg) {
      if (!mounted) return;
      // Avoid duplicate if already loaded from history
      final alreadyExists = _messages.any((m) => m.messageId == msg.messageId);
      if (!alreadyExists) {
        setState(() => _messages.add(msg));
        _scrollToBottom();
      }
      // Clear typing on any message
      setState(() => _typingUser = null);
    };

    _chatService.onUserTyping = (senderName) {
      if (!mounted) return;
      // Don't show typing indicator for self
      if (senderName == _myDisplayName) return;
      setState(() => _typingUser = '$senderName is typing...');
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _typingUser = null);
      });
    };

    _chatService.onError = (msg) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $msg'), backgroundColor: Colors.red),
      );
    };

    _chatService.onConnected = () {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _isConnected = true;
      });
      _chatService.joinRoom(
        widget.projectId,
        senderId: _myUserId,
        displayName: _myDisplayName,
      );
    };

    _chatService.onDisconnected = () {
      if (!mounted) return;
      setState(() => _isConnected = false);
    };

    _chatService.connect();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty || !_isConnected) return;

    _chatService.sendMessage(
      widget.projectId,
      text,
      senderId: _myUserId,
      displayName: _myDisplayName,
    );
    _textController.clear();
  }

  void _handleTyping() {
    if (_myUserId <= 0) return;
    _chatService.sendTyping(
      widget.projectId,
      senderId: _myUserId,
      displayName: _myDisplayName,
    );
  }

  @override
  void dispose() {
    _chatService.leaveRoom(widget.projectId);
    _chatService.disconnect();
    _textController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF666666),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.projectName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _isConnected
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _isConnecting
                      ? 'Connecting...'
                      : _isConnected
                      ? 'Online'
                      : 'Disconnected',
                  style: TextStyle(
                    fontSize: 11,
                    color: _isConnected
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: _isConnecting && _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF6C63FF)),
                        SizedBox(height: 12),
                        Text(
                          'Connecting to chat...',
                          style: TextStyle(color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                  )
                : _messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet.\nSay hello! 👋',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF999999), fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg.senderId == _myUserId;
                      final showDate =
                          index == 0 ||
                          !_isSameDay(_messages[index - 1].sentAt, msg.sentAt);
                      return Column(
                        children: [
                          if (showDate)
                            if (showDate) _DateDivider(date: msg.sentAt),
                          _ChatBubble(message: msg, isMe: isMe),
                        ],
                      );
                    },
                  ),
          ),

          // Typing indicator
          if (_typingUser != null)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _typingUser!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6C63FF),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

          // Input bar
          _ChatInputBar(
            controller: _textController,
            isConnected: _isConnected,
            onSend: _handleSend,
            onTyping: _handleTyping,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Today';
    } else {
      label = '${date.day}/${date.month}/${date.year}';
    }
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F0FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final time =
        '${message.sentAt.toLocal().hour.toString().padLeft(2, '0')}:${message.sentAt.toLocal().minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 36, bottom: 3),
              child: Text(
                message.senderName,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF999999),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(
                    0xFF6C63FF,
                  ).withValues(alpha: 0.15),
                  child: Text(
                    message.senderName.isNotEmpty
                        ? message.senderName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.68,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF6C63FF) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : const Color(0xFF1A1A1A),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 6),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
              ],
            ],
          ),
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 2),
              child: Text(
                time,
                style: const TextStyle(fontSize: 10, color: Color(0xFFB0B0B0)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isConnected;
  final VoidCallback onSend;
  final VoidCallback onTyping;

  const _ChatInputBar({
    required this.controller,
    required this.isConnected,
    required this.onSend,
    required this.onTyping,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                onChanged: (_) => onTyping(),
                onSubmitted: (_) => onSend(),
                enabled: isConnected,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: isConnected ? 'Type a message...' : 'Connecting...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isConnected ? onSend : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isConnected
                    ? const Color(0xFF6C63FF)
                    : const Color(0xFFCCCCCC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
