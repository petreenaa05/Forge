import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shimmer/shimmer.dart';

import 'package:forge/core/chat_theme.dart';
import 'package:forge/models/chat_model.dart';
import 'package:forge/providers/chat_provider.dart';
import 'package:forge/providers/auth_provider.dart' as app_auth;
import 'package:forge/services/chat_service.dart';

/// Chat list with staggered entrance animations.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;

  String get _myUid =>
      context.read<app_auth.AuthProvider>().uid ?? '';

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cp = Provider.of<ChatProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: ChatTheme.background,
      appBar: AppBar(
        backgroundColor: ChatTheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: ChatTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: ChatTheme.tertiary.withValues(alpha: 0.5)),
        ),
        actions: [
          StreamBuilder<int>(
            stream: cp.totalUnread(_myUid),
            builder: (context, snap) {
              final count = snap.data ?? 0;
              return AnimatedSwitcher(
                duration: ChatTheme.normal,
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: count > 0
                    ? Container(
                        key: ValueKey(count),
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: ChatTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count new',
                          style: const TextStyle(
                            color: ChatTheme.textOnPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('none')),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: cp.userChats(_myUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeleton();
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 48, color: ChatTheme.error),
                  const SizedBox(height: 12),
                  const Text('Couldn\'t load chats',
                      style: TextStyle(color: ChatTheme.textSecondary)),
                  TextButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry',
                        style: TextStyle(color: ChatTheme.primary)),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) return _buildEmpty();

          _staggerCtrl.reset();
          _staggerCtrl.forward();

          return RefreshIndicator(
            color: ChatTheme.primary,
            backgroundColor: ChatTheme.surface,
            onRefresh: () async =>
                await Future.delayed(const Duration(milliseconds: 400)),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chats.length,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(left: 82),
                child: Divider(
                  height: 1,
                  color: ChatTheme.tertiary.withValues(alpha: 0.5),
                ),
              ),
              itemBuilder: (context, index) {
                final start = (index * 0.08).clamp(0.0, 0.7);
                final end = (start + 0.3).clamp(0.0, 1.0);

                final tileAnim = Tween<Offset>(
                  begin: const Offset(0.15, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _staggerCtrl,
                  curve: Interval(start, end, curve: ChatTheme.curveSmooth),
                ));

                final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _staggerCtrl,
                    curve: Interval(start, end, curve: Curves.easeOut),
                  ),
                );

                return FadeTransition(
                  opacity: fadeAnim,
                  child: SlideTransition(
                    position: tileAnim,
                    child: _ChatTile(
                      chat: chats[index],
                      myUid: _myUid,
                      onTap: () {
                        Navigator.pushNamed(context, '/chat', arguments: {
                          'otherUid': chats[index].getOtherUid(_myUid),
                          'otherName': chats[index].getOtherName(_myUid),
                          'otherImage': chats[index].getOtherImage(_myUid),
                          'jobId': chats[index].jobId,
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: ChatTheme.tertiaryLight,
      highlightColor: ChatTheme.tertiarySurface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 7,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const CircleAvatar(radius: 28, backgroundColor: Colors.white),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      width: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 11,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: ChatTheme.entrance,
        curve: ChatTheme.curveSmooth,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: ChatTheme.primarySurface,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.forum_outlined,
                  size: 48,
                  color: ChatTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No conversations yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: ChatTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'When you connect with someone,\nyour chats will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: ChatTheme.textMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatTile extends StatefulWidget {
  final ChatModel chat;
  final String myUid;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chat,
    required this.myUid,
    required this.onTap,
  });

  @override
  State<_ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<_ChatTile> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final name = widget.chat.getOtherName(widget.myUid);
    final image = widget.chat.getOtherImage(widget.myUid);
    final otherUid = widget.chat.getOtherUid(widget.myUid);
    final unread = widget.chat.getUnreadCount(widget.myUid);
    final isTyping = widget.chat.isOtherTyping(widget.myUid);
    final isMySend = widget.chat.lastSenderId == widget.myUid;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: ChatTheme.fast,
        curve: ChatTheme.curveSmooth,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'avatar_$name',
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: ChatTheme.primarySurface,
                      backgroundImage: image.isNotEmpty
                          ? CachedNetworkImageProvider(image)
                          : null,
                      child: image.isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: ChatTheme.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                  StreamBuilder<UserPresence>(
                    stream: ChatService().streamPresence(otherUid),
                    builder: (context, snap) {
                      final online = snap.data?.online ?? false;
                      return Positioned(
                        right: 0,
                        bottom: 0,
                        child: AnimatedScale(
                          scale: online ? 1.0 : 0.0,
                          duration: ChatTheme.normal,
                          curve: ChatTheme.curveSpring,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: ChatTheme.onlineDot,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ChatTheme.surface,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: unread > 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: ChatTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeago.format(widget.chat.updatedAt,
                              locale: 'en_short'),
                          style: TextStyle(
                            fontSize: 12,
                            color: unread > 0
                                ? ChatTheme.primary
                                : ChatTheme.textMuted,
                            fontWeight: unread > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: ChatTheme.fast,
                            child: isTyping
                                ? const Text(
                                    'typing...',
                                    key: ValueKey('typing'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ChatTheme.primary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                : Text.rich(
                                    TextSpan(
                                      children: [
                                        if (isMySend &&
                                            widget.chat.lastMessage
                                                .isNotEmpty)
                                          const TextSpan(
                                            text: 'You: ',
                                            style: TextStyle(
                                              color: ChatTheme.textMuted,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        TextSpan(
                                          text: widget.chat
                                                  .lastMessagePreview
                                                  .isEmpty
                                              ? 'Start chatting...'
                                              : widget.chat
                                                  .lastMessagePreview,
                                        ),
                                      ],
                                    ),
                                    key: ValueKey(
                                        widget.chat.lastMessage),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: unread > 0
                                          ? ChatTheme.textPrimary
                                          : ChatTheme.textMuted,
                                      fontWeight: unread > 0
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ),

                        if (unread > 0) ...[
                          const SizedBox(width: 8),
                          AnimatedScale(
                            scale: 1.0,
                            duration: ChatTheme.normal,
                            curve: ChatTheme.curveSpring,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: ChatTheme.unreadBadge,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                unread > 99 ? '99+' : '$unread',
                                style: const TextStyle(
                                  color: ChatTheme.textOnPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
