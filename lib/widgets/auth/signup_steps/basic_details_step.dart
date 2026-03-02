import 'package:flutter/material.dart';

/// Step 3: Basic Account Details
/// User enters Full Name, Email, Password, and Confirm Password.
class BasicDetailsStep extends StatefulWidget {
  final VoidCallback onCreateAccount;
  final Function(String name, String email, String password) onDetailsChange;

  const BasicDetailsStep({
    super.key,
    required this.onCreateAccount,
    required this.onDetailsChange,
  });

  @override
  State<BasicDetailsStep> createState() => _BasicDetailsStepState();
}

class _BasicDetailsStepState extends State<BasicDetailsStep> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Map<String, String?> _errors = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final errors = <String, String?>{};

    // Full Name validation
    if (_nameController.text.trim().isEmpty) {
      errors['name'] = 'Full name is required';
    } else if (_nameController.text.trim().length < 2) {
      errors['name'] = 'Name must be at least 2 characters';
    } else {
      errors['name'] = null;
    }

    // Email validation
    if (_emailController.text.trim().isEmpty) {
      errors['email'] = 'Email address is required';
    } else if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(_emailController.text.trim())) {
      errors['email'] = 'Please enter a valid email address';
    } else {
      errors['email'] = null;
    }

    // Password validation
    if (_passwordController.text.isEmpty) {
      errors['password'] = 'Password is required';
    } else if (_passwordController.text.length < 6) {
      errors['password'] = 'Password must be at least 6 characters';
    } else {
      errors['password'] = null;
    }

    // Confirm Password validation
    if (_confirmPasswordController.text.isEmpty) {
      errors['confirmPassword'] = 'Please confirm your password';
    } else if (_passwordController.text != _confirmPasswordController.text) {
      errors['confirmPassword'] = 'Passwords do not match';
    } else {
      errors['confirmPassword'] = null;
    }

    setState(() => _errors = errors);

    // Return true if no errors
    return errors.values.every((error) => error == null);
  }

  void _handleCreateAccount() {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors below'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate account creation
    Future.delayed(const Duration(seconds: 2), () {
      widget.onDetailsChange(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      widget.onCreateAccount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Create Your Account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          const Text(
            'Enter your details to complete your Forge profile.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Full Name Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Full Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                onChanged: (_) {
                  if (_errors['name'] != null) {
                    setState(() => _errors['name'] = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAAAAAA),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errors['name'] != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFDDDDDD),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errors['name'] != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFDDDDDD),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errors['name'] != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFA82323),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              if (_errors['name'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errors['name']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Email Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Email Address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (_errors['email'] != null) {
                    setState(() => _errors['email'] = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'your.email@example.com',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAAAAAA),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errors['email'] != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFDDDDDD),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errors['email'] != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFDDDDDD),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errors['email'] != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFA82323),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              if (_errors['email'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errors['email']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Password Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) {
                  if (_errors['password'] != null) {
                    setState(() => _errors['password'] = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Minimum 6 characters',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAAAAAA),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errors['password'] != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFDDDDDD),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errors['password'] != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFDDDDDD),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errors['password'] != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFA82323),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF999999),
                      size: 20,
                    ),
                  ),
                ),
              ),
              if (_errors['password'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errors['password']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // Confirm Password Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Confirm Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                onChanged: (_) {
                  if (_errors['confirmPassword'] != null) {
                    setState(() => _errors['confirmPassword'] = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Re-enter your password',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAAAAAA),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errors['confirmPassword'] != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFDDDDDD),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errors['confirmPassword'] != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFDDDDDD),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _errors['confirmPassword'] != null
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFA82323),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      );
                    },
                    child: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF999999),
                      size: 20,
                    ),
                  ),
                ),
              ),
              if (_errors['confirmPassword'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errors['confirmPassword']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 40),

          // Create Account Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleCreateAccount,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // Terms and Conditions
          Center(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'By signing up, you agree to our ',
                    style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                  ),
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA82323),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text: ' and ',
                    style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA82323),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
