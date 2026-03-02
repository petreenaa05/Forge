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
      backgroundColor: const Color(0xFFFEFFD3), // Secondary color
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFFD3),
        elevation: 0,
        leading: _currentStep > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                color: const Color(0xFF2D2D2D),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              )
            : null,
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
              const SizedBox(height: 32),

              // Main Content
              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
            ],
          ),
        ),
      ),
    );
  }
}
