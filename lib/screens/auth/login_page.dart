import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:forge/providers/auth_provider.dart';

/// Login page — Aadhaar-based authentication.
/// Step 1: Enter 12-digit Aadhaar  →  Step 2: Verify OTP  →  Role Select
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _aadhaarController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false; // toggles between aadhaar-entry and otp-verify steps

  @override
  void dispose() {
    _aadhaarController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ── Step 1: Send OTP to Aadhaar-linked phone ────────────────
  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    await authProvider.sendOtp(_aadhaarController.text.trim());

    if (!mounted) return;

    if (authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      authProvider.clearError();
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _otpSent = true;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent to your Aadhaar-linked mobile number'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Step 2: Verify OTP ──────────────────────────────────────
  Future<void> _handleVerifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(_otpController.text.trim());

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Invalid OTP. Please try again.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      authProvider.clearError();
      setState(() => _isLoading = false);
      return;
    }

    // Navigate to role selection
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/role-select');
  }

  void _goBackToAadhaar() {
    setState(() {
      _otpSent = false;
      _otpController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    // ── Header ────────────────────────────────────
                    const Text(
                      'FORGE',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFA82323),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Secure Access with Aadhaar Verification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Auth Card ─────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _otpSent ? 'Verify OTP' : 'Login with Aadhaar',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Form(
                            key: _formKey,
                            child: _otpSent
                                ? _buildOtpStep()
                                : _buildAadhaarStep(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Sign Up Link ──────────────────────────────
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/signup');
                          },
                          child: const Text(
                            'Register here',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFA82323),
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
      ),
    );
  }

  // ── Aadhaar input step ────────────────────────────────────
  Widget _buildAadhaarStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Aadhaar icon
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFA82323).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.badge_rounded,
              size: 36,
              color: Color(0xFFA82323),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Aadhaar field
        TextFormField(
          controller: _aadhaarController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            labelText: 'Aadhaar Number',
            hintText: 'Enter 12-digit Aadhaar number',
            prefixIcon: const Icon(Icons.badge_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFA82323),
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Aadhaar number is required';
            }
            if (value!.length != 12) {
              return 'Aadhaar number must be exactly 12 digits';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        // Send OTP button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSendOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA82323),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor:
                const Color(0xFFA82323).withValues(alpha: 0.5),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Send OTP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Info box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_outline, size: 16, color: Color(0xFF888888)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your Aadhaar is encrypted and used only for verification.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── OTP verification step ─────────────────────────────────
  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Lock icon
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF6D9E51).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sms_rounded,
              size: 36,
              color: Color(0xFF6D9E51),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Subtitle
        Text(
          'OTP sent to Aadhaar-linked mobile',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),

        // Demo hint
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '🧪 Demo mode: enter any 6 digits',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFD97706),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // OTP field
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 10,
          ),
          decoration: InputDecoration(
            hintText: '------',
            hintStyle: TextStyle(
              fontSize: 24,
              color: Colors.grey.withValues(alpha: 0.4),
              letterSpacing: 10,
            ),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFA82323),
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter the OTP';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        // Verify button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleVerifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA82323),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            disabledBackgroundColor:
                const Color(0xFFA82323).withValues(alpha: 0.5),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Verify & Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Back + Resend row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: _goBackToAadhaar,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Change Aadhaar'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF666666),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('OTP resent successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFA82323),
              ),
              child: const Text(
                'Resend OTP',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
