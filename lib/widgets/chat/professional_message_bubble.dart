import 'package:flutter/material.dart';

/// Professional message bubble for chat with smooth animations
class ProfessionalMessageBubble extends StatefulWidget {
  final String message;
  final String timestamp;
  final bool isMe;
  final bool isSeen;
  final bool showSeenIndicator;

  const ProfessionalMessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isMe,
    this.isSeen = false,
    this.showSeenIndicator = false,
  });

  @override
  State<ProfessionalMessageBubble> createState() =>
      _ProfessionalMessageBubbleState();
}

class _ProfessionalMessageBubbleState extends State<ProfessionalMessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.isMe ? 0.3 : -0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: widget.isMe
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: widget.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isMe
                        ? const Color(0xFFA82323).withValues(alpha: 0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(widget.isMe ? 16 : 4),
                      bottomRight: Radius.circular(widget.isMe ? 4 : 16),
                    ),
                    border: widget.isMe
                        ? null
                        : Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    boxShadow: widget.isMe
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: widget.isMe
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFF374151),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.timestamp,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    if (widget.isMe && widget.showSeenIndicator) ...[
                      const SizedBox(width: 4),
                      Icon(
                        widget.isSeen ? Icons.done_all : Icons.done,
                        size: 14,
                        color: widget.isSeen
                            ? const Color(0xFF6D9E51)
                            : const Color(0xFF9CA3AF),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// System message for events (job confirmed, payment completed, etc.)
class SystemMessageWidget extends StatelessWidget {
  final String message;

  const SystemMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
