import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/core/theme/app_theme.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final phone = '+91${_phoneController.text.trim()}';
    await authProvider.sendOtp(phone);

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
      return;
    }

    if (authProvider.verificationId != null) {
      Navigator.of(context).pushNamed(
        '/otp-verify',
        arguments: _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top illustration banner
                  Container(
                    height: 250,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primary,
                          Color(0xFF4C1D95),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            '\u2692\uFE0F',
                            style: TextStyle(fontSize: 56),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'FORGE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          const Text(
                            'Welcome to Forge',
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Subtitle
                          const Text(
                            'Enter your phone number to continue',
                            style: TextStyle(
                              color: AppTheme.textMedium,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Phone input row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // +91 prefix chip
                              Container(
                                height: 58,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '+91',
                                    style: TextStyle(
                                      color: AppTheme.textDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Phone number field
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    hintText: '10-digit mobile number',
                                    hintStyle: const TextStyle(
                                      color: AppTheme.textMedium,
                                      fontSize: 15,
                                    ),
                                    counterText: '',
                                    filled: true,
                                    fillColor: AppTheme.background,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 18,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color:
                                            AppTheme.primary.withOpacity(0.3),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color:
                                            AppTheme.primary.withOpacity(0.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppTheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    if (val.trim().length != 10) {
                                      return 'Enter a valid 10-digit number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Send OTP button
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () => _sendOtp(authProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppTheme.primary.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Send OTP',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Footer note
                          const Text(
                            'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textMedium,
                              fontSize: 12,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
