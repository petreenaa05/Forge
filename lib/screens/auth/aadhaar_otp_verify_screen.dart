import 'package:flutter/material.dart';
import 'package:forge/widgets/auth/auth_card.dart';
import 'package:forge/widgets/auth/otp_input.dart';

class AadhaarOtpVerifyScreen extends StatefulWidget {
  const AadhaarOtpVerifyScreen({super.key});

  @override
  State<AadhaarOtpVerifyScreen> createState() => _AadhaarOtpVerifyScreenState();
}

class _AadhaarOtpVerifyScreenState extends State<AadhaarOtpVerifyScreen>
    with SingleTickerProviderStateMixin {
  late GlobalKey<State<OTPInput>> _otpKey;
  bool _isLoading = false;
  bool _showSuccess = false;
  String _enteredOtp = '';

  late AnimationController _successAnimCtrl;
  late Animation<double> _scaleAnim;

  // Mock OTP for demo
  static const String _mockOtp = '123456';

  @override
  void initState() {
    super.initState();
    _otpKey = GlobalKey();

    _successAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successAnimCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _successAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp(String otp) async {
    _enteredOtp = otp;
    // Validate OTP
    if (otp != _mockOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid OTP. Try 123456'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show success state
    setState(() => _showSuccess = true);
    _successAnimCtrl.forward();

    // Wait for animation
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // Navigate to role selection
    Navigator.of(context).pushReplacementNamed('/role-select');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFD3), // Secondary color
      body: SafeArea(
        child: _showSuccess ? _buildSuccessScreen() : _buildOtpScreen(),
      ),
    );
  }

  Widget _buildOtpScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // Forge Logo
                const Text(
                  'FORGE',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFA82323),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 32),
                // Auth Card
                AuthCard(
                  title: 'Verify Aadhaar OTP',
                  subtitle:
                      'Enter the 6-digit OTP sent to your registered phone',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // OTP Input
                      OTPInput(key: _otpKey, length: 6, onComplete: _verifyOtp),
                      const SizedBox(height: 32),
                      // Verify Button
                      ElevatedButton(
                        onPressed: _isLoading || _enteredOtp.isEmpty
                            ? null
                            : () {
                                if (_enteredOtp.length == 6) {
                                  _verifyOtp(_enteredOtp);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter all 6 digits',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA82323),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Complete Verification',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Resend OTP
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'OTP resent to your registered phone number',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text(
                          'Didn\'t receive OTP? Resend',
                          style: TextStyle(
                            color: Color(0xFF6D9E51),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF6D9E51),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Identity Verified Successfully',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your Aadhaar has been securely verified',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }
}
