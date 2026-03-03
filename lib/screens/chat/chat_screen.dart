import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/models/message_model.dart';
import 'package:forge/services/firestore_service.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/providers/user_provider.dart';
import 'package:forge/providers/chat_provider.dart';

// =============================================================================
// Design tokens — match Forge brand
// =============================================================================
class _C {
  static const Color maroon     = Color(0xFFA82323);
  static const Color maroonDark = Color(0xFF7A1818);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color black      = Color(0xFF000000);
  static const Color black50    = Color(0x80000000);
  static const Color black30    = Color(0x4D000000);
  static const Color border     = Color(0xFFE8E8E8);
  static const Color bg         = Color(0xFFF9F9F9);
}

/// Real-time chat screen between client and provider for a confirmed job.
///
/// Expects route arguments:
///   `{ 'jobId': String, 'otherUid': String, 'otherName': String }`
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirestoreService _db = FirestoreService();
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  String? _chatId;
  bool _initializing = true;

  late String _jobId;
  late String _otherUid;
  late String _otherName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializing) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _jobId = args?['jobId'] as String? ?? '';
    _otherUid = args?['otherUid'] as String? ?? '';
    _otherName = args?['otherName'] as String? ?? 'Chat';

    _initChat();
  }

  Future<void> _initChat() async {
    final uid = context.read<AuthProvider>().uid ?? '';
    final myName = context.read<UserProvider>().user?.name ?? '';

    final chatId = await _db.getOrCreateConversation(
      _jobId,
      [uid, _otherUid],
      {uid: myName, _otherUid: _otherName},
    );

    if (mounted) {
      // Mark this conversation as read
      context.read<ChatProvider>().markAsRead(chatId);
      setState(() {
        _chatId = chatId;
        _initializing = false;
      });
    }
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _chatId == null) return;

    final uid = context.read<AuthProvider>().uid ?? '';
    _msgCtrl.clear();

    final msg = MessageModel(
      id: '',
      senderId: uid,
      text: text,
      timestamp: DateTime.now(),
    );

    await _db.sendMessage(_chatId!, msg);

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().uid ?? '';

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.maroon,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _C.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _C.white,
              child: Text(
                _otherName.isNotEmpty ? _otherName[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: _C.maroon,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _otherName,
                    style: const TextStyle(
                      color: _C.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Forge Chat',
                    style: TextStyle(
                      color: _C.white.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _initializing || _chatId == null
          ? const Center(child: CircularProgressIndicator(color: _C.maroon))
          : Column(
              children: [
                // ── Messages ──────────────────────────────
                Expanded(
                  child: StreamBuilder<List<MessageModel>>(
                    stream: _db.getMessages(_chatId!),
                    builder: (context, snap) {
                      // Mark as read whenever new messages arrive
                      if (snap.hasData && _chatId != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.read<ChatProvider>().markAsRead(_chatId!);
                        });
                      }

                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(color: _C.maroon));
                      }
                      final messages = snap.data ?? [];
                      if (messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 56, color: _C.black.withValues(alpha: 0.12)),
                              const SizedBox(height: 12),
                              const Text(
                                'No messages yet.\nSay hello! 👋',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: _C.black50, fontSize: 15),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final m = messages[i];
                          final isMe = m.senderId == uid;
                          return _MessageBubble(message: m, isMe: isMe);
                        },
                      );
                    },
                  ),
                ),

                // ── Input bar ─────────────────────────────
                Container(
                  padding: EdgeInsets.only(
                    left: 14,
                    right: 10,
                    top: 10,
                    bottom: MediaQuery.of(context).padding.bottom + 10,
                  ),
                  decoration: BoxDecoration(
                    color: _C.white,
                    boxShadow: [
                      BoxShadow(
                          color: _C.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, -2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgCtrl,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Type a message…',
                            hintStyle: const TextStyle(color: _C.black30, fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: _C.bg,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _SendButton(onTap: _send),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// =============================================================================
// _SendButton — animated press effect
// =============================================================================

class _SendButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _pressed ? _C.maroonDark : _C.maroon,
            shape: BoxShape.circle,
            boxShadow: _pressed
                ? []
                : [BoxShadow(color: _C.maroon.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: const Icon(Icons.send_rounded, color: _C.white, size: 20),
        ),
      ),
    );
  }
}

// =============================================================================
// Message bubble — with entrance animation
// =============================================================================

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? _C.maroon : _C.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: _C.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? _C.white : _C.black,
                fontSize: 15,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: isMe
                    ? _C.white.withValues(alpha: 0.6)
                    : _C.black50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
