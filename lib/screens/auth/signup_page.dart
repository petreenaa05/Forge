import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/widgets/auth/step_indicator.dart';
import 'package:forge/widgets/auth/signup_steps/aadhaar_step.dart';
import 'package:forge/widgets/auth/signup_steps/otp_step.dart';
import 'package:forge/widgets/auth/signup_steps/basic_details_step.dart';

/// SignupPage: Orchestrates the 3-step signup process.
/// Step 1: Aadhaar Verification
/// Step 2: OTP Confirmation
/// Step 3: Basic Account Details
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late PageController _pageController;
  int _currentStep = 1;
  String _email = '';
  bool _isHoveredCard = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() => _currentStep = page + 1);
  }

  void _onAadhaarChange(String aadhaar) {
    // Store Aadhaar for later use if needed
  }

  void _onOtpChange(String otp) {
    // Store OTP for later use if needed
  }

  void _onDetailsChange(String name, String email, String password) {
    setState(() => _email = email);
  }

  Future<void> _handleCreateAccount() async {
    try {
      // Create user in Firebase Auth (simulated here)
      final authProvider = context.read<AuthProvider>();
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      // Set user in auth provider
      authProvider.setLoginUser(
        email: _email,
        uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      );

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully! Proceeding to role selection...',
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to role selection after a short delay
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        navigator.pushReplacementNamed('/role-select');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // White background
      body: SafeArea(
        child: Column(
          children: [
            // Professional Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
              child: Column(
                children: [
                  // Back Button and Logo Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button (visible from step 2 onwards)
                      _currentStep > 1
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back_ios_rounded),
                              color: const Color(0xFFA82323),
                              iconSize: 20,
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                            )
                          : const SizedBox(width: 48),

                      // Forge Logo
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA82323),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFA82323,
                              ).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.handyman_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 48), // Spacer for symmetry
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title Section
                  Column(
                    children: [
                      Text(
                        'Create Your Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2D2D2D),
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join Forge Community',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF666666),
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    // Step Indicator
                    StepIndicator(
                      currentStep: _currentStep,
                      totalSteps: 3,
                      title: _currentStep == 1
                          ? 'Identity Verification'
                          : _currentStep == 2
                          ? 'OTP Verification'
                          : 'Account Details',
                    ),
                    const SizedBox(height: 24),

                    // Main Content
                    Expanded(
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: MouseRegion(
                            onEnter: (_) =>
                                setState(() => _isHoveredCard = true),
                            onExit: (_) =>
                                setState(() => _isHoveredCard = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isHoveredCard
                                      ? const Color(0xFFA82323)
                                      : const Color(0xFFE5E7EB),
                                  width: _isHoveredCard ? 2.0 : 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _isHoveredCard
                                        ? const Color(
                                            0xFFA82323,
                                          ).withOpacity(0.15)
                                        : Colors.black.withOpacity(0.1),
                                    blurRadius: _isHoveredCard ? 16 : 8,
                                    offset: Offset(0, _isHoveredCard ? 8 : 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: PageView(
                                  controller: _pageController,
                                  onPageChanged: _onPageChanged,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    // Step 1: Aadhaar Input
                                    AadhaarStep(
                                      onSendOTP: _nextStep,
                                      onAadhaarChange: _onAadhaarChange,
                                    ),

                                    // Step 2: OTP Verification
                                    OtpStep(
                                      onVerifySuccess: _nextStep,
                                      onOtpChange: _onOtpChange,
                                    ),

                                    // Step 3: Basic Details
                                    BasicDetailsStep(
                                      onCreateAccount: _handleCreateAccount,
                                      onDetailsChange: _onDetailsChange,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
