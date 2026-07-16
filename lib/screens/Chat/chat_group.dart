import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ChatAppBar(title: 'Project Group', status: 'Hai is typing...'),
      body: Column(
        children: [
          const Expanded(child: ChatMessageList()),
          const ChatInputSection(),
          
        ],
      ),
    );
  }
}

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String status;

  const ChatAppBar({super.key, required this.title, required this.status});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF666666)), onPressed: () { if (Navigator.canPop(context)) { Navigator.pop(context); } }),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(status, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF666666)),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        DateDivider(label: 'Today'),
        SystemMessage(text: 'Hai pinned a message.'),
        SizedBox(height: 24),
        ChatBubble(
          name: 'Hai Nguyen',
          time: '10:42',
          message: 'Has everyone finished the report yet? We need to submit it tonight.',
          isMe: false,
        ),
        ChatBubble(
          name: 'Hai Nguyen',
          time: '10:42',
          message: 'I have just compiled the Word document here.',
          isMe: false,
          showAvatar: true,
          avatarUrl: 'https://i.pravatar.cc/100?img=12',
        ),
        SizedBox(height: 24),
        FileBubble(
          name: 'Linh Tran',
          time: '10:45',
          fileName: 'Draft_Report_v1.do...',
          fileSize: '2.4 MB',
          avatarUrl: 'https://i.pravatar.cc/100?img=32',
        ),
        SizedBox(height: 24),
        ChatBubble(
          name: 'You',
          time: '10:48',
          message: 'Sure, let me check the presentation slides and post them here.',
          isMe: true,
        ),
        TypingIndicator(),
      ],
    );
  }
}

class DateDivider extends StatelessWidget {
  final String label;
  const DateDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F0FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF666666), fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class SystemMessage extends StatelessWidget {
  final String text;
  const SystemMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: Color(0xFFB0B0B0), fontStyle: FontStyle.italic),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String name;
  final String time;
  final String message;
  final bool isMe;
  final bool showAvatar;
  final String? avatarUrl;

  const ChatBubble({
    super.key,
    required this.name,
    required this.time,
    required this.message,
    this.isMe = false,
    this.showAvatar = false,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe && !showAvatar)
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 4),
              child: Text('$name  $time', style: Theme.of(context).textTheme.labelSmall),
            ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                SizedBox(
                  width: 40,
                  child: showAvatar && avatarUrl != null
                      ? CircleAvatar(radius: 16, backgroundImage: NetworkImage(avatarUrl!))
                      : const SizedBox.shrink(),
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF6C63FF) : const Color(0xFFF3F0FF),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 20),
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.white : const Color(0xFF1A1A1A),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 8),
                Text(time, style: Theme.of(context).textTheme.labelSmall),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class FileBubble extends StatelessWidget {
  final String name;
  final String time;
  final String fileName;
  final String fileSize;
  final String avatarUrl;

  const FileBubble({
    super.key,
    required this.name,
    required this.time,
    required this.fileName,
    required this.fileSize,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 48, bottom: 4),
          child: Text('$name  $time', style: Theme.of(context).textTheme.labelSmall),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(radius: 16, backgroundImage: NetworkImage(avatarUrl)),
            const SizedBox(width: 8),
            Container(
              width: 240,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.description, color: Color(0xFF6C63FF), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(fileSize, style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
                      ],
                    ),
                  ),
                  const Icon(Icons.download_rounded, color: Color(0xFF6C63FF), size: 20),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, top: 8),
      child: Container(
        width: 50,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F0FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (i) =>
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(color: Color(0xFFB0B0B0), shape: BoxShape.circle),
              ),
          ),
        ),
      ),
    );
  }
}

class ChatInputSection extends StatelessWidget {
  const ChatInputSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F0FF),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF666666)),
              onPressed: () {},
            ),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF6C63FF),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F0FF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          NavItem(icon: Icons.home_outlined, label: 'Trang chủ'),
          NavItem(icon: Icons.folder_outlined, label: 'PROJECT'),
          NavItem(icon: Icons.notifications_none_rounded, label: 'Notifications'),
          NavItem(icon: Icons.chat_bubble_rounded, label: 'Chat', isActive: true),
          NavItem(icon: Icons.person_outline_rounded, label: 'Hồ sơ'),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const NavItem({super.key, required this.icon, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: isActive ? BoxDecoration(
            color: const Color(0xFFF3F0FF),
            borderRadius: BorderRadius.circular(16),
          ) : null,
          child: Icon(icon, color: isActive ? const Color(0xFF6C63FF) : const Color(0xFFB0B0B0)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF6C63FF) : const Color(0xFFB0B0B0),
          ),
        ),
      ],
    );
  }
}
