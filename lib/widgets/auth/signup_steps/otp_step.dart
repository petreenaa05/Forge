import 'package:flutter/material.dart';
import 'package:forge/widgets/auth/otp_input.dart';

/// Step 2: Aadhaar OTP Verification
/// User enters the 6-digit OTP sent to their Aadhaar-linked mobile.
/// Mock OTP: 123456
class OtpStep extends StatefulWidget {
  final VoidCallback onVerifySuccess;
  final Function(String otp) onOtpChange;

  const OtpStep({
    super.key,
    required this.onVerifySuccess,
    required this.onOtpChange,
  });

  @override
  State<OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<OtpStep> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String? _error;
  bool _isVerified = false;
  bool _isLoading = false;
  final GlobalKey<OTPInputState> _otpInputKey = GlobalKey<OTPInputState>();
  int _resendTimer = 30;
  late int _originalResendTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _originalResendTimer = _resendTimer;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _verifyOTP(String otp) {
    // Mock OTP verification
    // In production, this would validate against a backend service.
    const mockOTP = '123456';

    if (otp == mockOTP) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _isVerified = true;
            _error = null;
          });
          _animationController.forward();

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              widget.onVerifySuccess();
            }
          });
        }
      });
    } else {
      setState(() => _error = 'Invalid OTP. Try again.');
    }
  }

  void _handleOTPComplete(String otp) {
    widget.onOtpChange(otp);
    _verifyOTP(otp);
  }

  void _resendOTP() {
    // Reset timer
    setState(() {
      _resendTimer = _originalResendTimer;
      _error = null;
      // Clear OTP input
      _otpInputKey.currentState?.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent to your registered mobile number'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Enter Aadhaar OTP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Enter the 6-digit OTP sent to your Aadhaar-linked mobile number.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Demo OTP display (for hackathon)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFEFFD3),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF6D9E51),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demo OTP: 123456 (for testing)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6D9E51),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // OTP Input
              OTPInput(
                key: _otpInputKey,
                length: 6,
                onComplete: _handleOTPComplete,
              ),

              // Error message
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFD32F2F),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Resend OTP
              Center(
                child: GestureDetector(
                  onTap: _resendTimer == 0 ? _resendOTP : null,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "Didn't receive OTP? ",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                        TextSpan(
                          text: _resendTimer > 0
                              ? 'Resend in ${_resendTimer}s'
                              : 'Resend',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _resendTimer > 0
                                ? const Color(0xFF999999)
                                : const Color(0xFFA82323),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Verify Button
              if (!_isVerified)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            // Button is disabled; OTP is auto-verified on complete
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA82323),
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
            ],
          ),

          // Success Animation
          if (_isVerified)
            ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF6D9E51),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Identity Verified',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Successfully',
                      style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
