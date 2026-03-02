import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable OTP input widget with 6 separate boxes.
/// Auto-focuses next box on input.
class OTPInput extends StatefulWidget {
  final Function(String) onComplete;
  final int length;
  final TextEditingController? controller;

  const OTPInput({
    super.key,
    required this.onComplete,
    this.length = 6,
    this.controller,
  });

  @override
  State<OTPInput> createState() => OTPInputState();
}

class OTPInputState extends State<OTPInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleChange(int index, String value) {
    if (value.isEmpty) {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
      return;
    }

    if (value.length > 1) {
      _controllers[index].text = value[0];
    }

    // Auto-focus next box
    if (index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    // Check if all boxes are filled
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == widget.length) {
      widget.onComplete(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            widget.length,
            (index) => Container(
              width: 48,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDDDDDD)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) => _handleChange(index, value),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Get the complete OTP value
  String getOTP() => _controllers.map((c) => c.text).join();

  /// Clear all boxes
  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }
}
