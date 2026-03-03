import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/models/user_model.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/providers/user_provider.dart';
import 'package:forge/core/constants/app_constants.dart';

// =============================================================================
// Design Tokens
// =============================================================================
class _C {
  static const Color primary = Color(0xFFA82323);
  static const Color secondary = Color(0xFFFEFFD3);
  static const Color tertiary = Color(0xFF6D9E51);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color black80 = Color(0xCC000000);
  static const Color black30 = Color(0x4D000000);
  static const Color creamDark = Color(0xFFFBF7ED);
}

/// Premium role selection screen with polished UI.
/// User chooses "I Offer Services" (Freelancer) or "I Need Services" (Client).
class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen>
    with TickerProviderStateMixin {
  String? _selectedRole;
  bool _isLoading = false;
  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  void _selectRole(String role) {
    if (_selectedRole == role) return;
    setState(() => _selectedRole = role);
    _buttonController.forward(from: 0);
  }

  Future<void> _continueWithRole() async {
    if (_selectedRole == null) return;

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
      role: _selectedRole!,
    );

    await userProvider.createUser(newUser);

    if (!mounted) return;

    if (_selectedRole == UserRole.freelancer) {
      Navigator.of(context).pushReplacementNamed('/provider-setup');
    } else {
      Navigator.of(context).pushReplacementNamed('/client-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient and effects
          _BackgroundDecoration(),

          // Main content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 40,
                    vertical: 40,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Forge icon header
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _C.primary.withValues(alpha: 0.15),
                                _C.primary.withValues(alpha: 0.08),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _C.primary.withValues(alpha: 0.12),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🔧', style: TextStyle(fontSize: 48)),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title
                        const Text(
                          'How will you use Forge?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: _C.black80,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        const Text(
                          'You can switch roles anytime from your profile.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: _C.black30,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Divider
                        Opacity(
                          opacity: 0.3,
                          child: Container(
                            width: 80,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _C.primary.withValues(alpha: 0),
                                  _C.primary.withValues(alpha: 0.6),
                                  _C.primary.withValues(alpha: 0),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),

                        const SizedBox(height: 56),

                        // Role cards
                        LayoutBuilder(
                          builder: (_, constraints) {
                            final isStacked = constraints.maxWidth < 600;
                            return isStacked
                                ? Column(
                                    children: [
                                      _RoleCard(
                                        role: UserRole.freelancer,
                                        title: 'I Offer Services',
                                        subtitle:
                                            'Create your professional profile, accept jobs, and build your reputation.',
                                        icon: Icons.build_circle_outlined,
                                        iconColor: _C.primary,
                                        borderColor: _C.primary,
                                        isSelected:
                                            _selectedRole ==
                                            UserRole.freelancer,
                                        onTap: () =>
                                            _selectRole(UserRole.freelancer),
                                      ),
                                      const SizedBox(height: 20),
                                      _RoleCard(
                                        role: UserRole.client,
                                        title: 'I Need Services',
                                        subtitle:
                                            'Browse skilled professionals, book services, and leave reviews.',
                                        icon: Icons.people_alt_outlined,
                                        iconColor: _C.tertiary,
                                        borderColor: _C.tertiary,
                                        isSelected:
                                            _selectedRole == UserRole.client,
                                        onTap: () =>
                                            _selectRole(UserRole.client),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: _RoleCard(
                                          role: UserRole.freelancer,
                                          title: 'I Offer Services',
                                          subtitle:
                                              'Create your professional profile, accept jobs, and build your reputation.',
                                          icon: Icons.build_circle_outlined,
                                          iconColor: _C.primary,
                                          borderColor: _C.primary,
                                          isSelected:
                                              _selectedRole ==
                                              UserRole.freelancer,
                                          onTap: () =>
                                              _selectRole(UserRole.freelancer),
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: _RoleCard(
                                          role: UserRole.client,
                                          title: 'I Need Services',
                                          subtitle:
                                              'Browse skilled professionals, book services, and leave reviews.',
                                          icon: Icons.people_alt_outlined,
                                          iconColor: _C.tertiary,
                                          borderColor: _C.tertiary,
                                          isSelected:
                                              _selectedRole == UserRole.client,
                                          onTap: () =>
                                              _selectRole(UserRole.client),
                                        ),
                                      ),
                                    ],
                                  );
                          },
                        ),

                        const SizedBox(height: 48),

                        // Continue button
                        if (_selectedRole != null)
                          FadeTransition(
                            opacity: _buttonController,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.8, end: 1.0)
                                  .animate(
                                    CurvedAnimation(
                                      parent: _buttonController,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                              child: _ContinueButton(
                                isLoading: _isLoading,
                                onPressed: _continueWithRole,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Background Decoration
// =============================================================================
class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_C.secondary, _C.creamDark],
              stops: [0.0, 1.0],
            ),
          ),
        ),

        // Soft red glow behind header
        Positioned(
          top: -200,
          left: -100,
          right: -100,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _C.primary.withValues(alpha: 0.1),
                  blurRadius: 180,
                  spreadRadius: 80,
                ),
              ],
            ),
          ),
        ),

        // Floating abstract circle 1 (tertiary)
        Positioned(
          top: 100,
          right: 50,
          child: _FloatingShape(
            size: 220,
            color: _C.tertiary.withValues(alpha: 0.06),
            duration: const Duration(seconds: 10),
          ),
        ),

        // Floating abstract circle 2 (primary)
        Positioned(
          bottom: 150,
          left: 40,
          child: _FloatingShape(
            size: 180,
            color: _C.primary.withValues(alpha: 0.05),
            duration: const Duration(seconds: 14),
          ),
        ),

        // Floating abstract circle 3 (tertiary)
        Positioned(
          bottom: 50,
          right: 100,
          child: _FloatingShape(
            size: 150,
            color: _C.tertiary.withValues(alpha: 0.04),
            duration: const Duration(seconds: 18),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Floating Shape Animation
// =============================================================================
class _FloatingShape extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const _FloatingShape({
    required this.size,
    required this.color,
    required this.duration,
  });

  @override
  State<_FloatingShape> createState() => _FloatingShapeState();
}

class _FloatingShapeState extends State<_FloatingShape>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// Role Card
// =============================================================================
class _RoleCard extends StatefulWidget {
  final String role;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _checkmarkController;

  @override
  void initState() {
    super.initState();
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    if (widget.isSelected) {
      _checkmarkController.forward();
    }
  }

  @override
  void didUpdateWidget(_RoleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _checkmarkController.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _checkmarkController.reverse();
    }
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? widget.iconColor.withValues(alpha: 0.06)
              : _C.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: widget.borderColor, width: 4),
            top: BorderSide(
              color: widget.isSelected
                  ? widget.borderColor
                  : _C.black.withValues(alpha: 0.15),
              width: widget.isSelected ? 1.5 : 1,
            ),
            right: BorderSide(
              color: widget.isSelected
                  ? widget.borderColor
                  : _C.black.withValues(alpha: 0.15),
              width: widget.isSelected ? 1.5 : 1,
            ),
            bottom: BorderSide(
              color: widget.isSelected
                  ? widget.borderColor
                  : _C.black.withValues(alpha: 0.15),
              width: widget.isSelected ? 1.5 : 1,
            ),
          ),
          boxShadow: [
            if (_hovered || widget.isSelected)
              BoxShadow(
                color: widget.borderColor.withValues(
                  alpha: widget.isSelected ? 0.15 : 0.1,
                ),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            else
              BoxShadow(
                color: _C.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container with gradient
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.iconColor.withValues(
                            alpha: _hovered || widget.isSelected ? 0.25 : 0.18,
                          ),
                          widget.iconColor.withValues(
                            alpha: _hovered || widget.isSelected ? 0.15 : 0.10,
                          ),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 32,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title with underline animation
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _C.black80,
                                  ),
                                ),
                                Positioned(
                                  bottom: -3,
                                  left: 0,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: _hovered || widget.isSelected
                                        ? 50
                                        : 0,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: widget.iconColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.subtitle,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6A6A6A),
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Checkmark
                      ScaleTransition(
                        scale: Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(
                            parent: _checkmarkController,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: widget.iconColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: _C.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
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

// =============================================================================
// Continue Button
// =============================================================================
class _ContinueButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _ContinueButton({required this.isLoading, required this.onPressed});

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isLoading
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400, minHeight: 60),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isLoading
                ? [
                    _C.primary.withValues(alpha: 0.5),
                    _C.primary.withValues(alpha: 0.4),
                  ]
                : [
                    _hovered ? _C.primary : _C.primary.withValues(alpha: 0.95),
                    _hovered
                        ? Color.lerp(_C.primary, const Color(0xFF8B1A1A), 0.2)!
                        : Color.lerp(_C.primary, const Color(0xFF8B1A1A), 0.1)!,
                  ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _C.primary.withValues(alpha: _hovered ? 0.3 : 0.15),
              blurRadius: _hovered ? 24 : 16,
              offset: _hovered ? const Offset(0, 12) : const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Shine effect
            if (_hovered)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shineController,
                  builder: (_, __) {
                    return Opacity(
                      opacity: sin(_shineController.value * 3.14159) * 0.15,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    );
                  },
                ),
              ),
            // Button content
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onPressed,
                borderRadius: BorderRadius.circular(30),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              _C.white.withValues(alpha: 0.9),
                            ),
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _C.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Transform.translate(
                              offset: Offset(_hovered ? 4 : 0, 0),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: _C.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function for sine calculation
double sin(double x) {
  const List<double> sinValues = [
    0.0,
    0.258819,
    0.5,
    0.707107,
    0.866025,
    0.965926,
    1.0,
    0.965926,
    0.866025,
    0.707107,
    0.5,
    0.258819,
    0.0,
    -0.258819,
    -0.5,
    -0.707107,
  ];
  int index = ((x * 180 / 3.14159) % 360).toInt() ~/ 22;
  return sinValues[index.abs() % sinValues.length];
}
