import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:forge/core/chat_theme.dart';
import 'package:forge/models/chat_model.dart';

/// Custom chat app bar with smooth animated status transitions.
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String otherName;
  final String otherImage;
  final Stream<UserPresence>? presenceStream;
  final Stream<ChatModel?>? chatStream;
  final String myUid;
  final VoidCallback? onProfileTap;
  final VoidCallback onBack;

  const ChatAppBar({
    super.key,
    required this.otherName,
    required this.otherImage,
    required this.myUid,
    this.presenceStream,
    this.chatStream,
    this.onProfileTap,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ChatTheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            size: 20, color: ChatTheme.textPrimary),
        onPressed: onBack,
      ),
      titleSpacing: 0,
      title: GestureDetector(
        onTap: onProfileTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'avatar_$otherName',
                  child: CircleAvatar(
                    radius: 21,
                    backgroundColor: ChatTheme.primarySurface,
                    backgroundImage: otherImage.isNotEmpty
                        ? CachedNetworkImageProvider(otherImage)
                        : null,
                    child: otherImage.isEmpty
                        ? Text(
                            otherName.isNotEmpty
                                ? otherName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: ChatTheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                ),
                if (presenceStream != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: StreamBuilder<UserPresence>(
                      stream: presenceStream,
                      builder: (context, snap) {
                        final isOnline = snap.data?.online ?? false;
                        return AnimatedScale(
                          scale: isOnline ? 1.0 : 0.0,
                          duration: ChatTheme.normal,
                          curve: ChatTheme.curveSpring,
                          child: const _PulsingOnlineDot(),
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    otherName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ChatTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  _AnimatedStatusText(
                    chatStream: chatStream,
                    presenceStream: presenceStream,
                    myUid: myUid,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined,
              size: 24, color: ChatTheme.secondary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Video call coming soon!'),
                backgroundColor: ChatTheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded,
              color: ChatTheme.textSecondary),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'profile', child: Text('View Profile')),
            PopupMenuItem(value: 'mute', child: Text('Mute Chat')),
          ],
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: ChatTheme.tertiary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// Gently pulsing green online indicator dot.
class _PulsingOnlineDot extends StatefulWidget {
  const _PulsingOnlineDot();

  @override
  State<_PulsingOnlineDot> createState() => _PulsingOnlineDotState();
}

class _PulsingOnlineDotState extends State<_PulsingOnlineDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final opacity = 0.6 + (_ctrl.value * 0.4);
        return Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(
            color: ChatTheme.onlineDot.withValues(alpha: opacity),
            shape: BoxShape.circle,
            border: Border.all(color: ChatTheme.surface, width: 2.5),
          ),
        );
      },
    );
  }
}

/// Smoothly cross-fades between "typing...", "Online", and "last seen".
class _AnimatedStatusText extends StatelessWidget {
  final Stream<ChatModel?>? chatStream;
  final Stream<UserPresence>? presenceStream;
  final String myUid;

  const _AnimatedStatusText({
    this.chatStream,
    this.presenceStream,
    required this.myUid,
  });

  @override
  Widget build(BuildContext context) {
    if (chatStream == null && presenceStream == null) {
      return const SizedBox(height: 16);
    }

    return StreamBuilder<ChatModel?>(
      stream: chatStream,
      builder: (context, chatSnap) {
        final isTyping = chatSnap.data?.isOtherTyping(myUid) ?? false;

        if (isTyping) {
          return _statusText('typing...', ChatTheme.primary, italic: true);
        }

        return StreamBuilder<UserPresence>(
          stream: presenceStream,
          builder: (context, presSnap) {
            final presence = presSnap.data;
            if (presence == null) return const SizedBox(height: 16);

            if (presence.online) {
              return _statusText('Online', ChatTheme.primary);
            }

            return _statusText(
              'Last seen ${timeago.format(presence.lastSeen)}',
              ChatTheme.textMuted,
            );
          },
        );
      },
    );
  }

  Widget _statusText(String text, Color color, {bool italic = false}) {
    return AnimatedSwitcher(
      duration: ChatTheme.normal,
      switchInCurve: ChatTheme.curveSmooth,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        text,
        key: ValueKey(text),
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
