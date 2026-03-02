import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Step 1: Aadhaar Number Input
/// User enters their 12-digit Aadhaar number.
class AadhaarStep extends StatefulWidget {
  final VoidCallback onSendOTP;
  final Function(String aadhaar) onAadhaarChange;

  const AadhaarStep({
    super.key,
    required this.onSendOTP,
    required this.onAadhaarChange,
  });

  @override
  State<AadhaarStep> createState() => _AadhaarStepState();
}

class _AadhaarStepState extends State<AadhaarStep> {
  late TextEditingController _aadhaarController;
  late FocusNode _aadhaarFocus;
  String? _error;

  @override
  void initState() {
    super.initState();
    _aadhaarController = TextEditingController();
    _aadhaarFocus = FocusNode();
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _aadhaarFocus.dispose();
    super.dispose();
  }

  void _validateAndSend() {
    final aadhaar = _aadhaarController.text.trim();

    if (aadhaar.isEmpty) {
      setState(() => _error = 'Aadhaar number is required');
      return;
    }

    if (aadhaar.length != 12) {
      setState(() => _error = 'Aadhaar must be 12 digits');
      return;
    }

    if (!RegExp(r'^\d{12}$').hasMatch(aadhaar)) {
      setState(() => _error = 'Aadhaar must contain only numbers');
      return;
    }

    setState(() => _error = null);
    widget.onAadhaarChange(aadhaar);
    widget.onSendOTP();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Verify Your Identity',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          const Text(
            'To maintain a secure and trusted women-only ecosystem, Aadhaar verification is required before account creation.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Aadhaar Input Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aadhaar Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _aadhaarController,
                focusNode: _aadhaarFocus,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                onChanged: (_) {
                  if (_error != null) {
                    setState(() => _error = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: '0000 0000 0000',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAAAAAA),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _error != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFDDDDDD),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _error != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFDDDDDD),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _error != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFA82323),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: _aadhaarController.text.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            _aadhaarController.text.length == 12
                                ? Icons.check_circle
                                : Icons.info_outline,
                            color: _aadhaarController.text.length == 12
                                ? const Color(0xFF6D9E51)
                                : const Color(0xFFAAAAAA),
                          ),
                        )
                      : null,
                ),
              ),

              // Error message
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD32F2F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 40),

          // Send OTP Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _validateAndSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA82323),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Send OTP',
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
    );
  }
}
