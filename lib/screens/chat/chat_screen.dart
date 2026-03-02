import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:forge/core/chat_theme.dart';
import 'package:forge/models/chat_message_model.dart';
import 'package:forge/models/chat_model.dart';
import 'package:forge/providers/chat_provider.dart';
import 'package:forge/providers/auth_provider.dart' as app_auth;
import 'package:forge/providers/user_provider.dart';

import 'package:forge/widgets/chat/message_bubble.dart';
import 'package:forge/widgets/chat/typing_indicator.dart';
import 'package:forge/widgets/chat/chat_input_bar.dart';
import 'package:forge/widgets/chat/chat_app_bar.dart';
import 'package:forge/widgets/chat/date_separator.dart';
import 'image_viewer_screen.dart';

/// Main real-time chat screen.
///
/// Navigation:
/// ```dart
/// Navigator.pushNamed(context, '/chat', arguments: {
///   'otherUid': 'abc123',
///   'otherName': 'Jane',
///   'otherImage': 'https://...',
///   'jobId': 'optional',
/// });
/// ```
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  bool _showScrollFab = false;
  bool _isInitialized = false;

  late AnimationController _emptyCtrl;
  late Animation<double> _emptyFade;
  late Animation<Offset> _emptySlide;

  String get _myUid =>
      context.read<app_auth.AuthProvider>().uid ?? '';
  String get _myName =>
      context.read<UserProvider>().user?.name ?? '';
  String get _myImage => '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollCtrl.addListener(_onScroll);

    _emptyCtrl = AnimationController(
      duration: ChatTheme.entrance,
      vsync: this,
    );
    _emptyFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _emptyCtrl, curve: ChatTheme.curveSmooth),
    );
    _emptySlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _emptyCtrl, curve: ChatTheme.curveSmooth),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initChat();
      _isInitialized = true;
    }
  }

  Future<void> _initChat() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    await chatProvider.openChat(
      myUid: _myUid,
      myName: _myName,
      myImage: _myImage,
      otherUid: args['otherUid'] as String,
      otherName: args['otherName'] as String,
      otherImage: args['otherImage'] as String? ?? '',
      jobId: args['jobId'] as String?,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cp = Provider.of<ChatProvider>(context, listen: false);
    if (state == AppLifecycleState.paused) {
      cp.goOffline(_myUid);
    } else if (state == AppLifecycleState.resumed) {
      cp.goOnline(_myUid);
      cp.markAsRead(_myUid);
    }
  }

  void _onScroll() {
    final pos = _scrollCtrl.position;
    final atBottom = pos.pixels >= pos.maxScrollExtent - 120;
    if (_showScrollFab == atBottom) {
      setState(() => _showScrollFab = !atBottom);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollCtrl.hasClients) return;
    if (animated) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: ChatTheme.normal,
        curve: ChatTheme.curveSmooth,
      );
    } else {
      _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Provider.of<ChatProvider>(context, listen: false).closeChat(_myUid);
    _scrollCtrl.dispose();
    _emptyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cp = Provider.of<ChatProvider>(context);
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final otherName = cp.activeOtherName ?? args?['otherName'] ?? 'User';
    final otherImage = cp.activeOtherImage ?? args?['otherImage'] ?? '';

    return Scaffold(
      backgroundColor: ChatTheme.background,

      appBar: ChatAppBar(
        otherName: otherName,
        otherImage: otherImage,
        myUid: _myUid,
        presenceStream: cp.otherUserPresence,
        chatStream: cp.activeChatStream,
        onBack: () {
          cp.closeChat(_myUid);
          Navigator.pop(context);
        },
      ),

      body: Column(
        children: [
          Expanded(
            child: cp.activeChatId == null
                ? Center(
                    child: CircularProgressIndicator(
                      color: ChatTheme.primary,
                      strokeWidth: 2,
                    ),
                  )
                : StreamBuilder<List<MessageModel>>(
                    stream: cp.activeMessages,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: ChatTheme.primary,
                            strokeWidth: 2,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildError();
                      }

                      final streamed = snapshot.data ?? [];
                      final all = [...cp.olderMessages, ...streamed];

                      if (all.isEmpty) {
                        _emptyCtrl.forward();
                        return _buildEmpty(otherName);
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!_showScrollFab) {
                          _scrollToBottom(animated: false);
                        }
                      });

                      cp.markAsRead(_myUid);

                      return ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        itemCount: all.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0 && cp.isLoadingMore) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: ChatTheme.secondary,
                                  ),
                                ),
                              ),
                            );
                          }

                          if (index == all.length) {
                            return StreamBuilder<ChatModel?>(
                              stream: cp.activeChatStream,
                              builder: (context, chatSnap) {
                                final typing = chatSnap.data
                                        ?.isOtherTyping(_myUid) ??
                                    false;
                                return AnimatedSwitcher(
                                  duration: ChatTheme.normal,
                                  transitionBuilder: (child, anim) =>
                                      FadeTransition(
                                          opacity: anim, child: child),
                                  child: typing
                                      ? TypingIndicator(userName: otherName)
                                      : const SizedBox.shrink(
                                          key: ValueKey('no-typing')),
                                );
                              },
                            );
                          }

                          final msg = all[index];
                          final isMe = msg.senderId == _myUid;

                          final showDate = DateSeparator.shouldShow(
                            index > 0 ? all[index - 1].timestamp : null,
                            msg.timestamp,
                          );

                          return Column(
                            children: [
                              if (showDate) DateSeparator(date: msg.timestamp),
                              MessageBubble(
                                message: msg,
                                isMe: isMe,
                                currentUid: _myUid,
                                index: index,
                                onImageTap: msg.imageUrl != null
                                    ? () => _openImage(
                                        msg.imageUrl!,
                                        isMe ? _myName : otherName,
                                      )
                                    : null,
                                onLongPress: () =>
                                    _showOptions(context, msg),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
          ),

          ChatInputBar(
            onSendText: (msg) {
              cp.sendTextMessage(senderId: _myUid, message: msg);
              Future.delayed(const Duration(milliseconds: 100),
                  () => _scrollToBottom());
            },
            onSendImage: (source) {
              cp.pickAndSendImage(senderId: _myUid, source: source);
            },
            onTyping: () => cp.onTyping(_myUid),
            onStopTyping: () => cp.onStopTyping(_myUid),
            isSending: cp.isSending,
            isUploadingImage: cp.isUploadingImage,
          ),
        ],
      ),

      floatingActionButton: AnimatedScale(
        scale: _showScrollFab ? 1.0 : 0.0,
        duration: ChatTheme.normal,
        curve: ChatTheme.curveSpring,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: FloatingActionButton.small(
            onPressed: () => _scrollToBottom(),
            backgroundColor: ChatTheme.surface,
            elevation: 4,
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: ChatTheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(String otherName) {
    return FadeTransition(
      opacity: _emptyFade,
      child: SlideTransition(
        position: _emptySlide,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: ChatTheme.primarySurface,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 36,
                    color: ChatTheme.primary,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Start the conversation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ChatTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Say hello to $otherName and\ndiscuss your project.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ChatTheme.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _QuickReply(
                      text: '👋 Hello!',
                      onTap: () => _quickSend('Hello! 👋'),
                    ),
                    _QuickReply(
                      text: 'Interested!',
                      onTap: () => _quickSend(
                          'Hi! I\'m interested in your services.'),
                    ),
                    _QuickReply(
                      text: 'Available?',
                      onTap: () => _quickSend(
                          'Are you available for a new project?'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: ChatTheme.error),
          const SizedBox(height: 12),
          const Text('Couldn\'t load messages',
              style: TextStyle(color: ChatTheme.textSecondary)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _initChat,
            style: TextButton.styleFrom(foregroundColor: ChatTheme.primary),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _quickSend(String msg) {
    Provider.of<ChatProvider>(context, listen: false)
        .sendTextMessage(senderId: _myUid, message: msg);
  }

  void _openImage(String url, String name) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            ImageViewerScreen(imageUrl: url, senderName: name),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: ChatTheme.normal,
      ),
    );
  }

  void _showOptions(BuildContext context, MessageModel msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ChatTheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: ChatTheme.tertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                leading: const Icon(Icons.copy_rounded,
                    color: ChatTheme.textSecondary),
                title: const Text('Copy'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Copied'),
                      backgroundColor: ChatTheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
              if (msg.senderId == _myUid)
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: ChatTheme.error),
                  title: const Text('Delete',
                      style: TextStyle(color: ChatTheme.error)),
                  onTap: () => Navigator.pop(ctx),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickReply extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _QuickReply({required this.text, required this.onTap});

  @override
  State<_QuickReply> createState() => _QuickReplyState();
}

class _QuickReplyState extends State<_QuickReply> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.92),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: ChatTheme.fast,
        curve: ChatTheme.curveSpring,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: ChatTheme.primarySurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ChatTheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              color: ChatTheme.primary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
