import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:forge/core/chat_theme.dart';
import 'package:forge/models/chat_message_model.dart';

/// Animated message bubble that slides and fades in on first render.
///
/// Supports text, image, job-update, and system message types.
class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final String currentUid;
  final int index;
  final VoidCallback? onImageTap;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.currentUid,
    this.index = 0,
    this.onImageTap,
    this.onLongPress,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      duration: ChatTheme.normal,
      vsync: this,
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: ChatTheme.curveSmooth),
    );

    _slideAnim = Tween<Offset>(
      begin: Offset(widget.isMe ? 0.15 : -0.15, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animCtrl, curve: ChatTheme.curveSpring),
    );

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: ChatTheme.curveSmooth),
    );

    final delay = Duration(
      milliseconds: (widget.index * ChatTheme.stagger.inMilliseconds)
          .clamp(0, 300),
    );
    Future.delayed(delay, () {
      if (mounted) _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.type == MessageType.system) {
      return _buildSystemMessage();
    }
    if (widget.message.type == MessageType.jobUpdate) {
      return _buildJobUpdateMessage();
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          alignment: widget.isMe
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Align(
            alignment: widget.isMe
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: GestureDetector(
              onLongPress: widget.onLongPress,
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: widget.isMe
                      ? ChatTheme.myBubble
                      : ChatTheme.theirBubble,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(widget.isMe ? 20 : 4),
                    bottomRight: Radius.circular(widget.isMe ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isMe
                          ? ChatTheme.primary.withValues(alpha: 0.18)
                          : ChatTheme.secondary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: widget.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (widget.message.type == MessageType.image &&
                        widget.message.imageUrl != null)
                      _buildImage(),

                    if (!(widget.message.type == MessageType.image &&
                        widget.message.message == '📷 Photo'))
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          14,
                          widget.message.type == MessageType.image ? 6 : 12,
                          14,
                          2,
                        ),
                        child: Text(
                          widget.message.message,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: widget.isMe
                                ? ChatTheme.textOnPrimary
                                : ChatTheme.textPrimary,
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 3, 10, 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(widget.message.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: widget.isMe
                                  ? Colors.white.withValues(alpha: 0.6)
                                  : ChatTheme.textMuted,
                            ),
                          ),
                          if (widget.isMe) ...[
                            const SizedBox(width: 4),
                            _buildReadReceipt(),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return GestureDetector(
      onTap: widget.onImageTap,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: CachedNetworkImage(
          imageUrl: widget.message.imageUrl!,
          width: 240,
          height: 200,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: 240,
            height: 200,
            color: ChatTheme.primarySurface,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ChatTheme.primary,
                ),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            width: 240,
            height: 200,
            color: ChatTheme.tertiaryLight,
            child: const Icon(Icons.broken_image_rounded,
                color: ChatTheme.textMuted),
          ),
        ),
      ),
    );
  }

  Widget _buildReadReceipt() {
    final isRead = widget.message.readBy.length > 1;
    if (widget.message.status == MessageStatus.sending) {
      return Icon(Icons.access_time_rounded,
          size: 14, color: Colors.white.withValues(alpha: 0.45));
    }
    return AnimatedSwitcher(
      duration: ChatTheme.fast,
      child: Icon(
        isRead ? Icons.done_all_rounded : Icons.done_rounded,
        key: ValueKey(isRead),
        size: 16,
        color: isRead
            ? ChatTheme.readTick
            : Colors.white.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildSystemMessage() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ChatTheme.tertiary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.message.message,
              style: const TextStyle(
                fontSize: 12,
                color: ChatTheme.textMuted,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobUpdateMessage() {
    final status = widget.message.jobUpdate?['status'] ?? '';
    Color color;
    IconData icon;

    switch (status) {
      case 'accepted':
        color = ChatTheme.primary;
        icon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        color = ChatTheme.error;
        icon = Icons.cancel_rounded;
        break;
      case 'completed':
        color = ChatTheme.primary;
        icon = Icons.celebration_rounded;
        break;
      default:
        color = ChatTheme.warning;
        icon = Icons.info_rounded;
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animCtrl,
          curve: ChatTheme.curveSmooth,
        )),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message.message,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: color,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeago.format(widget.message.timestamp),
                      style: const TextStyle(
                        fontSize: 11,
                        color: ChatTheme.textMuted,
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

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
