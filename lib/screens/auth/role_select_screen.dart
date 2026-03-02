import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/models/user_model.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/providers/user_provider.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/core/constants/app_constants.dart';
import 'package:forge/widgets/auth/role_card.dart';

/// Professional role selection screen.
/// User chooses "I Offer Services" (Freelancer) or "I Need Services" (Client).
/// Features selection state, hover effects, and responsive layout.
class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _handleContinue() async {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFEFFD3), // Secondary cream background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Forge Logo Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.handyman_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    'How will you use Forge?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'You can switch roles anytime from your profile.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xFF666666)),
                  ),
                  const SizedBox(height: 56),

                  // Role Cards
                  if (isDesktop) ...[
                    // Side-by-side layout for desktop
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RoleCard(
                            icon: Icons.work_outline_rounded,
                            title: 'I Offer Services',
                            description:
                                'Create your professional profile, accept jobs, and build your reputation.',
                            accentColor: AppTheme.primary,
                            isSelected: _selectedRole == UserRole.freelancer,
                            onTap: () => setState(
                              () => _selectedRole = UserRole.freelancer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: RoleCard(
                            icon: Icons.person_outline_rounded,
                            title: 'I Need Services',
                            description:
                                'Browse skilled professionals, book services, and leave reviews.',
                            accentColor: AppTheme.tertiary,
                            isSelected: _selectedRole == UserRole.client,
                            onTap: () =>
                                setState(() => _selectedRole = UserRole.client),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Stacked layout for tablet and mobile
                    RoleCard(
                      icon: Icons.work_outline_rounded,
                      title: 'I Offer Services',
                      description:
                          'Create your professional profile, accept jobs, and build your reputation.',
                      accentColor: AppTheme.primary,
                      isSelected: _selectedRole == UserRole.freelancer,
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.freelancer),
                    ),
                    const SizedBox(height: 20),
                    RoleCard(
                      icon: Icons.person_outline_rounded,
                      title: 'I Need Services',
                      description:
                          'Browse skilled professionals, book services, and leave reviews.',
                      accentColor: AppTheme.tertiary,
                      isSelected: _selectedRole == UserRole.client,
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.client),
                    ),
                  ],
                  const SizedBox(height: 48),

                  // Continue Button
                  SizedBox(
                    width: isDesktop ? 400 : double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _selectedRole == null || _isLoading
                          ? null
                          : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        disabledBackgroundColor: const Color(0xFFE0E0E0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: _selectedRole != null ? 2 : 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  const Text(
                    'Forge — Women\'s Services Marketplace',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF999999)),
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
