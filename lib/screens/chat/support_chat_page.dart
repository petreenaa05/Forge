import 'package:flutter/material.dart';

// =============================================================================
// Design tokens
// =============================================================================
class _C {
  static const Color primary = Color(0xFFA82323);
  static const Color secondary = Color(0xFFFEFFD3);
  static const Color tertiary = Color(0xFF6D9E51);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color black80 = Color(0xCC000000);
  static const Color black50 = Color(0x80000000);
  static const Color black30 = Color(0x4D000000);
  static const Color border = Color(0xFFE8E8E8);
}

/// AI Support Chatbot for Forge marketplace.
/// Helps users understand platform features, verification, booking, etc.
class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _msgCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _typingCtrl;

  final List<_ChatMessage> _messages = [];
  bool _isTyping = false;

  // Quick reply suggestions
  final List<String> _suggestions = [
    'How does booking work?',
    'How is Aadhaar verified?',
    'How do ratings work?',
    'How to switch roles?',
    'Is Forge safe?',
  ];

  @override
  void initState() {
    super.initState();
    _typingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Send welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendBotMessage(
        'Hello! I\'m the Forge Support Assistant.\n\n'
        'I can help you understand how Forge works, how to book services, '
        'and how verification is handled.',
      );
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    _typingCtrl.dispose();
    super.dispose();
  }

  void _sendBotMessage(String text, {bool isWelcome = false}) {
    setState(() {
      _messages.add(
        _ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isUser: false,
          isWelcome: isWelcome,
          timestamp: DateTime.now(),
        ),
      );
    });

    _scrollToBottom();
  }

  void _sendUserMessage(String text) {
    // Add user message
    setState(() {
      _messages.add(
        _ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate bot typing and response
    _typingCtrl.forward().then((_) => _typingCtrl.reset());

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isTyping = false);
        _sendBotMessage(_getBotResponse(text));
      }
    });
  }

  String _getBotResponse(String userMessage) {
    final msg = userMessage.toLowerCase();

    if (msg.contains('booking') || msg.contains('book')) {
      return 'Booking Flow:\n\n'
          '• Browse professionals by skill and rating\n'
          '• Send a service request with details\n'
          '• Discuss terms via in-app chat\n'
          '• Confirm booking when ready\n'
          '• Complete work and payment\n'
          '• Rate and review\n\n'
          'Payment is secured through Forge\'s platform.';
    } else if (msg.contains('aadhaar') || msg.contains('verif')) {
      return 'Identity Verification:\n\n'
          '• Aadhaar verification ensures authenticity\n'
          '• Your data is encrypted and secure\n'
          '• Verified badge appears on your profile\n'
          '• Verification is required for all professionals\n'
          '• Clients see your verified status\n\n'
          'Your privacy is our priority.';
    } else if (msg.contains('rating') || msg.contains('reputation')) {
      return 'Ratings & Reputation:\n\n'
          '• Ratings are given after job completion\n'
          '• Scale: 1 (poor) to 5 (excellent) stars\n'
          '• Reviews can include written feedback\n'
          '• Your rating appears on your profile\n'
          '• Higher ratings increase visibility\n'
          '• Ratings are transparent and honest\n\n'
          'Build your professional reputation over time.';
    } else if (msg.contains('role') || msg.contains('switch')) {
      return 'Role Switching:\n\n'
          '• You can be both a service provider and client\n'
          '• Switch roles from your dashboard\n'
          '• Each role has its own profile and ratings\n'
          '• Separate booking history for each role\n'
          '• No restrictions on switching\n\n'
          'Flexibility is built into Forge.';
    } else if (msg.contains('safe') || msg.contains('safety')) {
      return 'Safety on Forge:\n\n'
          '• Women-only verified professional network\n'
          '• Identity verification for all users\n'
          '• Safe in-app communication\n'
          '• No phone numbers shared directly\n'
          '• Dispute resolution support\n'
          '• Report unsafe behavior\n\n'
          'Your safety and security are paramount.';
    } else if (msg.contains('onboard') || msg.contains('freelancer')) {
      return 'Freelancer Onboarding:\n\n'
          '• Sign up with email\n'
          '• Complete Aadhaar verification\n'
          '• Create your professional profile\n'
          '• Add skills and experience\n'
          '• Set your service rates\n'
          '• Start receiving requests\n\n'
          'The process typically takes 5-10 minutes.';
    } else if (msg.contains('price') ||
        msg.contains('cost') ||
        msg.contains('payment')) {
      return 'Pricing & Payment:\n\n'
          '• Professionals set their own rates\n'
          '• Payment is processed securely\n'
          '• Transactions happen through Forge\n'
          '• Payment protection for both parties\n'
          '• Transparent pricing with no hidden fees\n'
          '• Withdrawals available weekly\n\n'
          'Financial security is guaranteed.';
    } else if (msg.toLowerCase().isEmpty) {
      return 'Please ask me something about Forge.';
    } else {
      return 'I\'m here to help with Forge-related questions. '
          'Try asking about booking, verification, ratings, safety, '
          'or how to get started.';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleQuickReply(String suggestion) {
    setState(() {
      _suggestions.remove(suggestion);
    });
    _msgCtrl.clear();
    _sendUserMessage(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.secondary,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _C.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (_isTyping && i == _messages.length) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TypingIndicator(animation: _typingCtrl),
                          );
                        }

                        final msg = _messages[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 220),
                            tween: Tween(begin: 0.92, end: 1.0),
                            builder: (context, scale, child) {
                              return Opacity(
                                opacity: scale,
                                child: Transform.scale(
                                  scale: scale,
                                  alignment: msg.isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: child,
                                ),
                              );
                            },
                            child: msg.isUser
                                ? _UserMessageBubble(message: msg)
                                : _BotMessageBubble(message: msg),
                          ),
                        );
                      },
                    ),
            ),
          ),
          // Quick suggestions (show only if no messages yet)
          if (_messages.length <= 1 && _suggestions.isNotEmpty)
            _buildQuickSuggestions(),
          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _C.white,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: _C.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _C.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.support_agent_rounded,
                color: _C.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Forge Support Assistant',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _C.black,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.verified_rounded, size: 16, color: _C.tertiary),
                  ],
                ),
                Text(
                  'Here to help you understand Forge',
                  style: TextStyle(
                    fontSize: 11,
                    color: _C.black50,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _C.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              size: 48,
              color: _C.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Forge Support Assistant',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _C.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Here to answer your questions',
            style: TextStyle(
              fontSize: 14,
              color: _C.black50,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: _suggestions
            .map(
              (suggestion) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _QuickReplyChip(
                  label: suggestion,
                  onTap: () => _handleQuickReply(suggestion),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        boxShadow: [
          BoxShadow(
            color: _C.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Ask something about Forge...',
                    hintStyle: TextStyle(color: _C.black30, fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide(color: _C.border, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide(color: _C.border, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(26),
                      borderSide: BorderSide(color: _C.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: _C.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14, color: _C.black),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) {
                    final text = _msgCtrl.text.trim();
                    if (text.isNotEmpty) {
                      _sendUserMessage(text);
                      _msgCtrl.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              _SendButton(
                onPressed: () {
                  final text = _msgCtrl.text.trim();
                  if (text.isNotEmpty) {
                    _sendUserMessage(text);
                    _msgCtrl.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Chat message data model
// =============================================================================

class _ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final bool isWelcome;
  final DateTime timestamp;

  _ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.isWelcome = false,
    required this.timestamp,
  });
}

// =============================================================================
// Message bubbles
// =============================================================================

class _BotMessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _BotMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.80,
        ),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: _C.tertiary, width: 3)),
          boxShadow: [
            BoxShadow(
              color: _C.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: const TextStyle(
                color: _C.black80,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: _C.black.withValues(alpha: 0.3),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _UserMessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _UserMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.80,
        ),
        decoration: BoxDecoration(
          color: _C.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _C.primary.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _C.black.withValues(alpha: 0.04),
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
              style: const TextStyle(
                color: _C.black80,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: _C.black.withValues(alpha: 0.3),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// =============================================================================
// Quick reply chip
// =============================================================================

class _QuickReplyChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickReplyChip({required this.label, required this.onTap});

  @override
  State<_QuickReplyChip> createState() => _QuickReplyChipState();
}

class _QuickReplyChipState extends State<_QuickReplyChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? _C.primary : _C.white,
            border: Border.all(color: _C.primary, width: 1.5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: _C.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _hovered ? _C.white : _C.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Typing indicator
// =============================================================================

class _TypingIndicator extends StatelessWidget {
  final AnimationController animation;

  const _TypingIndicator({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: _C.tertiary, width: 3)),
          boxShadow: [
            BoxShadow(
              color: _C.black.withValues(alpha: 0.06),
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
              animation: animation,
              builder: (context, child) {
                final delay = index * 0.2;
                final animValue = (animation.value - delay).clamp(0.0, 1.0);
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
                        color: _C.primary,
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
    );
  }
}

// =============================================================================
// Send button
// =============================================================================

class _SendButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _SendButton({required this.onPressed});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _pressed ? _C.primary.withValues(alpha: 0.9) : _C.primary,
            shape: BoxShape.circle,
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: _C.primary.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: _C.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: const Icon(Icons.send_rounded, color: _C.white, size: 21),
        ),
      ),
    );
  }
}

// =============================================================================
// Floating Chatbot Button — appears in bottom right corner
// =============================================================================

class FloatingChatbotButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const FloatingChatbotButton({super.key, this.onPressed});

  @override
  State<FloatingChatbotButton> createState() => _FloatingChatbotButtonState();
}

class _FloatingChatbotButtonState extends State<FloatingChatbotButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut));

    _pulseAnim =
        Tween<double>(begin: 1.0, end: 1.1).animate(
          CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _animCtrl.reverse();
          } else if (status == AnimationStatus.dismissed) {
            _animCtrl.forward();
          }
        });

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Positioned(
      right: 20,
      bottom: bottomInset + 20,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTap: () {
            if (widget.onPressed != null) {
              widget.onPressed!();
            } else {
              Navigator.of(context).pushNamed('/support-chat');
            }
          },
          child: ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_C.primary, _C.primary.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _C.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: _C.primary.withValues(alpha: 0.2),
                    blurRadius: 24,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.support_agent_rounded, color: _C.white, size: 28),
                  const SizedBox(height: 2),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _C.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
