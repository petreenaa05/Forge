import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:forge/core/chat_theme.dart';

/// Animated typing indicator with smooth sine-wave bouncing dots.
class TypingIndicator extends StatefulWidget {
  final String userName;

  const TypingIndicator({super.key, required this.userName});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8, left: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: ChatTheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: ChatTheme.secondary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.userName,
                style: const TextStyle(
                  fontSize: 12,
                  color: ChatTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              ...List.generate(3, (i) => _BouncingDot(
                controller: _ctrl,
                phaseOffset: i * 0.28,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single dot that oscillates vertically using sine wave.
class _BouncingDot extends StatelessWidget {
  final AnimationController controller;
  final double phaseOffset;

  const _BouncingDot({
    required this.controller,
    required this.phaseOffset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = math.sin(
          (controller.value + phaseOffset) * 2 * math.pi,
        );
        return Transform.translate(
          offset: Offset(0, value * -4),
          child: Opacity(
            opacity: 0.4 + (value + 1) * 0.3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: ChatTheme.typingDot,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
