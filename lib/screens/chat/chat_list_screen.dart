import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/models/message_model.dart';
import 'package:forge/services/firestore_service.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/providers/chat_provider.dart';

// =============================================================================
// Design tokens — match Forge brand
// =============================================================================
class _C {
  static const Color maroon     = Color(0xFFA82323);
  static const Color maroonDark = Color(0xFF7A1818);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color black      = Color(0xFF000000);
  static const Color black80    = Color(0xCC000000);
  static const Color black50    = Color(0x80000000);
  static const Color black30    = Color(0x4D000000);
  static const Color border     = Color(0xFFE8E8E8);
  static const Color green      = Color(0xFF2E7D32);
}

/// Lists all conversations the current user is a participant in.
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().uid ?? '';
    final db = FirestoreService();

    return Scaffold(
      backgroundColor: _C.white,
      appBar: AppBar(
        backgroundColor: _C.maroon,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _C.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Forge',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: _C.white,
            letterSpacing: 0.8,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Messages',
                style: TextStyle(
                  color: _C.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<ConversationModel>>(
        stream: db.getConversations(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _C.maroon),
            );
          }

          final convos = snap.data ?? [];

          if (convos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 64, color: _C.black.withValues(alpha: 0.12)),
                  const SizedBox(height: 16),
                  const Text(
                    'No conversations yet',
                    style: TextStyle(
                      color: _C.black80,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Chats appear when a job is accepted.',
                    style: TextStyle(color: _C.black50, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: convos.length,
            separatorBuilder: (_, __) => Container(
              margin: const EdgeInsets.only(left: 76),
              height: 1,
              color: _C.border,
            ),
            itemBuilder: (_, i) {
              final c = convos[i];
              final otherUid =
                  c.participants.firstWhere((p) => p != uid, orElse: () => '');
              final otherName =
                  c.participantNames[otherUid] ?? 'Unknown';
              final hasUnread = c.unreadBy[uid] == true;

              return _ChatListTile(
                otherName: otherName,
                lastMessage: c.lastMessage,
                updatedAt: c.updatedAt,
                hasUnread: hasUnread,
                onTap: () {
                  // Mark as read
                  context.read<ChatProvider>().markAsRead(c.id);
                  Navigator.of(context).pushNamed(
                    '/chat',
                    arguments: {
                      'jobId': c.jobId,
                      'otherUid': otherUid,
                      'otherName': otherName,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// =============================================================================
// _ChatListTile — individual conversation row with hover effect
// =============================================================================

class _ChatListTile extends StatefulWidget {
  final String otherName;
  final String lastMessage;
  final DateTime updatedAt;
  final bool hasUnread;
  final VoidCallback onTap;

  const _ChatListTile({
    required this.otherName,
    required this.lastMessage,
    required this.updatedAt,
    required this.hasUnread,
    required this.onTap,
  });

  @override
  State<_ChatListTile> createState() => _ChatListTileState();
}

class _ChatListTileState extends State<_ChatListTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          color: _hovered
              ? _C.maroon.withValues(alpha: 0.04)
              : widget.hasUnread
                  ? _C.maroon.withValues(alpha: 0.02)
                  : _C.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: _C.maroon,
                child: Text(
                  widget.otherName.isNotEmpty
                      ? widget.otherName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: _C.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name + message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherName,
                      style: TextStyle(
                        fontWeight: widget.hasUnread
                            ? FontWeight.w700
                            : FontWeight.w600,
                        fontSize: 15,
                        color: _C.black,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.lastMessage.isNotEmpty
                          ? widget.lastMessage
                          : 'No messages yet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.hasUnread ? _C.black80 : _C.black50,
                        fontSize: 13,
                        fontWeight: widget.hasUnread
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Time + unread dot
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _timeAgo(widget.updatedAt),
                    style: TextStyle(
                      color: widget.hasUnread ? _C.maroon : _C.black50,
                      fontSize: 12,
                      fontWeight: widget.hasUnread
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (widget.hasUnread)
                    Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(
                        color: _C.maroon,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
