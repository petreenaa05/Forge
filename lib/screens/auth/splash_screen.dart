import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/providers/user_provider.dart';
import 'package:forge/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _animController.forward();

    Future.delayed(const Duration(milliseconds: 2500), _checkAuthAndNavigate);
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      _navigateTo('/login');
      return;
    }

    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.loadUser(authProvider.uid!);

      if (!mounted) return;

      final userModel = userProvider.user;

      if (userModel == null) {
        _navigateTo('/role-select');
      } else if (userModel.role == 'freelancer') {
        _navigateTo('/provider-home');
      } else {
        _navigateTo('/client-home');
      }
    } catch (_) {
      if (mounted) {
        _navigateTo('/login');
      }
    }
  }

  void _navigateTo(String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary,
              Color(0xFF4C1D95),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '\u2692\uFE0F',
                      style: TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'FORGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 60,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Women's Services Marketplace",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Column(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white54,
                        strokeWidth: 2.5,
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
