import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/models/user_model.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/providers/user_provider.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/core/constants/app_constants.dart';

/// First-time role selection screen.
/// User chooses "I Offer Services" (Freelancer) or "I Need Services" (Client).
class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  bool _isLoading = false;

  Future<void> _selectRole(String role) async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final uid = authProvider.uid;
    final phone = authProvider.phone ?? '';

    if (uid == null) {
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    final userProvider = context.read<UserProvider>();

    final newUser = UserModel(
      uid: uid,
      name: '',
      phone: phone,
      role: role,
    );

    await userProvider.createUser(newUser);

    if (!mounted) return;

    if (role == UserRole.freelancer) {
      Navigator.of(context).pushReplacementNamed('/provider-setup');
    } else {
      Navigator.of(context).pushReplacementNamed('/client-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Header
              const Text(
                '⚒️',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'How will you use Forge?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can switch roles anytime from your profile.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textMedium,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 48),

              // Freelancer card
              _RoleCard(
                emoji: '👩‍🔧',
                title: 'I Offer Services',
                subtitle:
                    'Create your professional profile, accept jobs, and build your reputation.',
                color: AppTheme.primary,
                isLoading: _isLoading,
                onTap: () => _selectRole(UserRole.freelancer),
              ),

              const SizedBox(height: 20),

              // Client card
              _RoleCard(
                emoji: '👤',
                title: 'I Need Services',
                subtitle:
                    'Browse skilled professionals, book services, and leave reviews.',
                color: const Color(0xFF2E7D32),
                isLoading: _isLoading,
                onTap: () => _selectRole(UserRole.client),
              ),

              const Spacer(),

              // Footer
              const Text(
                'Forge — Women\'s Services Marketplace',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textMedium,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered ? widget.color : widget.color.withValues(alpha: 0.2),
            width: _hovered ? 2 : 1,
          ),
          boxShadow: _hovered
              ? [BoxShadow(color: widget.color.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6))]
              : [BoxShadow(color: widget.color.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Emoji circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _hovered
                          ? widget.color
                          : widget.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(widget.emoji, style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 16),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMedium,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _hovered ? widget.color.withValues(alpha: 0.1) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_ios, color: widget.color, size: 18),
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
