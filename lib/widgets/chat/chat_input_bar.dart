import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:forge/core/chat_theme.dart';

/// Chat input bar with smooth morphing send button.
class ChatInputBar extends StatefulWidget {
  final Function(String message) onSendText;
  final Function(ImageSource source) onSendImage;
  final VoidCallback onTyping;
  final VoidCallback onStopTyping;
  final bool isSending;
  final bool isUploadingImage;

  const ChatInputBar({
    super.key,
    required this.onSendText,
    required this.onSendImage,
    required this.onTyping,
    required this.onStopTyping,
    this.isSending = false,
    this.isUploadingImage = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  late AnimationController _sendBtnCtrl;

  @override
  void initState() {
    super.initState();

    _sendBtnCtrl = AnimationController(
      duration: ChatTheme.normal,
      vsync: this,
    );

    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
        if (hasText) {
          _sendBtnCtrl.forward();
        } else {
          _sendBtnCtrl.reverse();
        }
      }
      if (hasText) widget.onTyping();
    });

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) widget.onStopTyping();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _sendBtnCtrl.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendText(text);
    _controller.clear();
    widget.onStopTyping();
    setState(() => _hasText = false);
    _sendBtnCtrl.reverse();
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ChatTheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: ChatTheme.tertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _ImageSourceTile(
                  icon: Icons.photo_library_rounded,
                  title: 'Gallery',
                  subtitle: 'Choose from photos',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onSendImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 4),
                _ImageSourceTile(
                  icon: Icons.camera_alt_rounded,
                  title: 'Camera',
                  subtitle: 'Take a new photo',
                  onTap: () {
                    Navigator.pop(context);
                    widget.onSendImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ChatTheme.surface,
        boxShadow: [
          BoxShadow(
            color: ChatTheme.secondary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: ChatTheme.normal,
              curve: ChatTheme.curveSmooth,
              child: widget.isUploadingImage
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ChatTheme.primary,
                              backgroundColor: ChatTheme.primarySurface,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Sending image...',
                            style: TextStyle(
                              fontSize: 12,
                              color: ChatTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _AnimatedIconButton(
                    icon: Icons.add_circle_outline_rounded,
                    onTap: widget.isUploadingImage
                        ? null
                        : _showImageSourcePicker,
                    color: ChatTheme.secondary,
                  ),
                  const SizedBox(width: 6),

                  Expanded(
                    child: AnimatedContainer(
                      duration: ChatTheme.fast,
                      curve: ChatTheme.curveSmooth,
                      decoration: BoxDecoration(
                        color: _focusNode.hasFocus
                            ? ChatTheme.primarySurface.withValues(alpha: 0.5)
                            : ChatTheme.inputBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? ChatTheme.primary.withValues(alpha: 0.3)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 5,
                        minLines: 1,
                        style: const TextStyle(
                          fontSize: 15,
                          color: ChatTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: ChatTheme.textMuted.withValues(alpha: 0.7),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  AnimatedContainer(
                    duration: ChatTheme.normal,
                    curve: ChatTheme.curveSmooth,
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _hasText
                          ? ChatTheme.primary
                          : ChatTheme.primarySurface,
                      borderRadius: BorderRadius.circular(23),
                      boxShadow: _hasText
                          ? [
                              BoxShadow(
                                color: ChatTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(23),
                        onTap: _hasText && !widget.isSending
                            ? _handleSend
                            : null,
                        child: Center(
                          child: widget.isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: ChatTheme.textOnPrimary,
                                  ),
                                )
                              : AnimatedSwitcher(
                                  duration: ChatTheme.fast,
                                  transitionBuilder: (child, anim) {
                                    return ScaleTransition(
                                      scale: anim,
                                      child: RotationTransition(
                                        turns: Tween<double>(
                                          begin: 0.8,
                                          end: 1.0,
                                        ).animate(anim),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    _hasText
                                        ? Icons.send_rounded
                                        : Icons.mic_none_rounded,
                                    key: ValueKey(_hasText),
                                    size: 22,
                                    color: _hasText
                                        ? ChatTheme.textOnPrimary
                                        : ChatTheme.primary,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ImageSourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ChatTheme.primarySurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: ChatTheme.primary, size: 22),
      ),
      title: Text(title, style: const TextStyle(
        fontWeight: FontWeight.w500, color: ChatTheme.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(
        fontSize: 12, color: ChatTheme.textMuted)),
      onTap: onTap,
    );
  }
}

class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _AnimatedIconButton({
    required this.icon,
    this.onTap,
    required this.color,
  });

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.85),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: ChatTheme.fast,
        curve: ChatTheme.curveSpring,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(widget.icon, color: widget.color, size: 28),
        ),
      ),
    );
  }
}
