import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forge/widgets/auth/auth_card.dart';

class AadhaarInputScreen extends StatefulWidget {
  const AadhaarInputScreen({super.key});

  @override
  State<AadhaarInputScreen> createState() => _AadhaarInputScreenState();
}

class _AadhaarInputScreenState extends State<AadhaarInputScreen> {
  final TextEditingController _aadhaarController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _aadhaarController.dispose();
    super.dispose();
  }

  void _sendAadhaarOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate OTP sending
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isLoading = false);

    // Navigate to Aadhaar OTP verification screen
    Navigator.of(context).pushNamed(
      '/aadhaar-otp-verify',
      arguments: _aadhaarController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFD3), // Secondary color
      body: SafeArea(
        child: SingleChildScrollView(
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
                      title: 'Identity Verification Required',
                      subtitle:
                          'To maintain a trusted and women-only professional ecosystem, Aadhaar verification is required.',
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Aadhaar Input
                            TextFormField(
                              controller: _aadhaarController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(12),
                              ],
                              decoration: InputDecoration(
                                hintText: 'Enter 12-digit Aadhaar number',
                                prefixIcon: const Icon(Icons.badge_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFDDD),
                                  ),
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
                                  return 'Aadhaar must be 12 digits';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            // Send OTP Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _sendAadhaarOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA82323),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Send Aadhaar OTP',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            // Info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '📌 Your Aadhaar number is securely encrypted and used only for verification purposes.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF666666),
                                  height: 1.5,
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
            ),
          ),
        ),
      ),
    );
  }
}
