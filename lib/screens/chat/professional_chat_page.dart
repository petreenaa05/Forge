import 'package:flutter/material.dart';
import 'package:forge/widgets/chat/chat_header.dart';
import 'package:forge/widgets/chat/job_context_card.dart';
import 'package:forge/widgets/chat/professional_message_bubble.dart';

/// Professional chat page for Forge marketplace
/// Optimized for Client-Freelancer communication on confirmed jobs
class ProfessionalChatPage extends StatefulWidget {
  const ProfessionalChatPage({super.key});

  @override
  State<ProfessionalChatPage> createState() => _ProfessionalChatPageState();
}

class _ProfessionalChatPageState extends State<ProfessionalChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;

  // Demo data - replace with actual data from your backend
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      message: 'Hi! I\'m confirmed for your electrical repair job.',
      timestamp: '10:30 AM',
      isMe: false,
      isSeen: true,
    ),
    ChatMessage(
      id: '2',
      message: 'Great! Can you arrive by 2 PM?',
      timestamp: '10:32 AM',
      isMe: true,
      isSeen: true,
    ),
    ChatMessage(
      id: '3',
      message:
          'Yes, I\'ll be there exactly at 2 PM. Please keep the main switch accessible.',
      timestamp: '10:35 AM',
      isMe: false,
      isSeen: true,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: text,
          timestamp: _formatTime(DateTime.now()),
          isMe: true,
          isSeen: false,
        ),
      );
      _messageController.clear();
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFEFFD3), // Secondary cream background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFEFFD3),
              const Color(0xFFFEFFD3).withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 800 : double.infinity,
            ),
            child: Column(
              children: [
                // Header
                ChatHeader(
                  userName: 'Priya Sharma',
                  isVerified: true,
                  isOnline: true,
                  jobReference: 'Job: Home Electrical Repair | 25 Mar 2026',
                  onBackPressed: () => Navigator.of(context).pop(),
                ),

                // Job Context Card
                const JobContextCard(
                  jobTitle: 'Home Electrical Repair',
                  scheduledDate: '25 Mar 2026, 2:00 PM',
                  status: 'Confirmed',
                ),

                // Messages List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == _messages.length) {
                        return const _TypingIndicator();
                      }

                      final message = _messages[index];
                      return ProfessionalMessageBubble(
                        message: message.message,
                        timestamp: message.timestamp,
                        isMe: message.isMe,
                        isSeen: message.isSeen,
                        showSeenIndicator: index == _messages.length - 1,
                      );
                    },
                  ),
                ),

                // Message Input Area
                _buildMessageInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Attachment button
              IconButton(
                icon: const Icon(Icons.attach_file_rounded),
                onPressed: () {
                  // Handle attachment
                },
                color: const Color(0xFF6B7280),
                iconSize: 24,
              ),
              const SizedBox(width: 8),

              // Text input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF2D2D2D),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value) {
                      setState(() {
                        _isTyping = value.trim().isNotEmpty;
                      });
                    },
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Send button
              _SendButton(
                onPressed: _sendMessage,
                enabled: _messageController.text.trim().isNotEmpty,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data model for chat messages
class ChatMessage {
  final String id;
  final String message;
  final String timestamp;
  final bool isMe;
  final bool isSeen;

  ChatMessage({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.isMe,
    required this.isSeen,
  });
}

/// Animated send button with gradient and shadow
class _SendButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool enabled;

  const _SendButton({required this.onPressed, this.enabled = true});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;

    _controller.forward().then((_) {
      _controller.reverse();
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: widget.enabled
                ? const LinearGradient(
                    colors: [Color(0xFFA82323), Color(0xFF8A1D1D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.enabled ? null : const Color(0xFFE5E7EB),
            shape: BoxShape.circle,
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: const Color(0xFFA82323).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            Icons.send_rounded,
            color: widget.enabled ? Colors.white : const Color(0xFF9CA3AF),
            size: 22,
          ),
        ),
      ),
    );
  }
}

/// Typing indicator animation
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (index) => AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final delay = index * 0.2;
                  final animValue = (_controller.value - delay).clamp(0.0, 1.0);
                  final opacity =
                      (animValue < 0.5 ? animValue * 2 : (1 - animValue) * 2)
                          .clamp(0.3, 1.0);

                  return Padding(
                    padding: EdgeInsets.only(left: index > 0 ? 4 : 0),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF9CA3AF),
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
