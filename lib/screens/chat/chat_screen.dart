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
  static const Color maroon = Color(0xFFA82323);
  static const Color maroonDark = Color(0xFF7A1818);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color black80 = Color(0xCC000000);
  static const Color black50 = Color(0x80000000);
  static const Color black30 = Color(0x4D000000);
  static const Color border = Color(0xFFE8E8E8);
  static const Color bg = Color(0xFFF9F9F9);
  static const Color green = Color(0xFF2E7D32);
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
  final FocusNode _focusNode = FocusNode();

  String? _chatId;
  bool _initializing = true;
  String? _error;
  bool _isTyping = false;

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

    if (_jobId.isEmpty || _otherUid.isEmpty) {
      setState(() {
        _error = 'Invalid chat parameters. Missing job or user information.';
        _initializing = false;
      });
    } else {
      _initChat();
    }
  }

  Future<void> _initChat() async {
    try {
      final uid = context.read<AuthProvider>().uid ?? '';
      final myName = context.read<UserProvider>().user?.name ?? '';

      if (uid.isEmpty) {
        throw Exception('User not authenticated');
      }

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
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load chat: ${e.toString()}';
          _initializing = false;
        });
      }
    }
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _chatId == null) return;

    final uid = context.read<AuthProvider>().uid ?? '';
    _msgCtrl.clear();
    setState(() => _isTyping = false);

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

  bool _differentDate(DateTime date1, DateTime date2) {
    return date1.year != date2.year ||
        date1.month != date2.month ||
        date1.day != date2.day;
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
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
                  fontWeight: FontWeight.bold,
                ),
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
                    'Verified Professional',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: _C.white),
            onPressed: () {},
            tooltip: 'Job details',
          ),
        ],
      ),
      body: _initializing
          ? const Center(child: CircularProgressIndicator(color: _C.maroon))
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 56,
                    color: _C.black.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _C.black.withValues(alpha: 0.6),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            )
          : _chatId == null
          ? const Center(child: CircularProgressIndicator(color: _C.maroon))
          : Column(
              children: [
                // ── Job Context Card ──────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _C.maroon.withValues(alpha: 0.08),
                        _C.maroon.withValues(alpha: 0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.maroon.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.work_outline_rounded,
                        color: _C.maroon,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Job',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _C.maroon,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Job ID: $_jobId',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _C.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _C.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Confirmed',
                          style: TextStyle(
                            color: _C.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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
                          child: CircularProgressIndicator(color: _C.maroon),
                        );
                      }
                      final messages = snap.data ?? [];
                      final uid = context.read<AuthProvider>().uid ?? '';

                      if (messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 56,
                                color: _C.black.withValues(alpha: 0.12),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No messages yet.\nSay hello! 👋',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _C.black50,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        itemCount: messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (_isTyping && i == messages.length) {
                            return _TypingIndicator(name: _otherName);
                          }

                          final m = messages[i];
                          final isMe = m.senderId == uid;

                          // Show date separator if this is first message or date changed
                          final showDateSeparator =
                              i == 0 ||
                              _differentDate(
                                messages[i - 1].timestamp,
                                messages[i].timestamp,
                              );

                          return Column(
                            children: [
                              if (showDateSeparator)
                                _DateSeparator(date: m.timestamp),
                              _MessageBubble(message: m, isMe: isMe),
                            ],
                          );
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
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgCtrl,
                          focusNode: _focusNode,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Type a message…',
                            hintStyle: const TextStyle(
                              color: _C.black30,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: _C.bg,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _isTyping = value.trim().isNotEmpty;
                            });
                          },
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _SendButton(onTap: _send, enabled: _isTyping),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// =============================================================================
// _SendButton — animated press effect with enable/disable state
// =============================================================================

class _SendButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool enabled;
  const _SendButton({required this.onTap, this.enabled = true});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: widget.enabled
          ? () => setState(() => _pressed = false)
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: widget.enabled
                ? (_pressed ? _C.maroonDark : _C.maroon)
                : _C.border,
            shape: BoxShape.circle,
            boxShadow: widget.enabled && !_pressed
                ? [
                    BoxShadow(
                      color: _C.maroon.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            Icons.send_rounded,
            color: widget.enabled ? _C.white : _C.black30,
            size: 20,
          ),
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMe) ...[
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: _C.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? _C.white.withValues(alpha: 0.6) : _C.black50,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Date Separator
// =============================================================================

class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date});

  String _formatDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month]}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: _C.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _formatDate(),
              style: TextStyle(
                fontSize: 12,
                color: _C.black.withValues(alpha: 0.4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: Divider(color: _C.border)),
        ],
      ),
    );
  }
}

// =============================================================================
// _TypingIndicator — animated dots showing other user is typing
// =============================================================================

class _TypingIndicator extends StatefulWidget {
  final String name;
  const _TypingIndicator({required this.name});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _C.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (index) => AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) {
                  final delay = index * 0.2;
                  final animValue = (_ctrl.value - delay).clamp(0.0, 1.0);
                  final opacity =
                      (animValue < 0.5 ? animValue * 2 : (1 - animValue) * 2)
                          .clamp(0.3, 1.0);

                  return Padding(
                    padding: EdgeInsets.only(left: index > 0 ? 6 : 0),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: _C.maroon,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
