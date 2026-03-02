import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:forge/core/chat_theme.dart';

/// Animated date separator between message groups.
class DateSeparator extends StatefulWidget {
  final DateTime date;

  const DateSeparator({super.key, required this.date});

  @override
  State<DateSeparator> createState() => _DateSeparatorState();

  /// Determine if a separator should appear between two timestamps.
  static bool shouldShow(DateTime? previous, DateTime current) {
    if (previous == null) return true;
    return previous.year != current.year ||
        previous.month != current.month ||
        previous.day != current.day;
  }
}

class _DateSeparatorState extends State<DateSeparator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: ChatTheme.slow,
      vsync: this,
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: ChatTheme.curveSmooth),
    );
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: ChatTheme.curveSpring),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 0.5,
                  color: ChatTheme.tertiary.withValues(alpha: 0.6),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: ChatTheme.secondarySurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ChatTheme.tertiary.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    _formatDate(widget.date),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ChatTheme.secondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 0.5,
                  color: ChatTheme.tertiary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(messageDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(date);
    return DateFormat('EEE, d MMM').format(date);
  }
}
