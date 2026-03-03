import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/providers/auth_provider.dart';

/// Demo screen to easily test WhatsApp-like chat between Freelancer and Client
/// Shows conversation setup and allows quick chat opening
class ChatDemoScreen extends StatefulWidget {
  const ChatDemoScreen({super.key});

  @override
  State<ChatDemoScreen> createState() => _ChatDemoScreenState();
}

class _ChatDemoScreenState extends State<ChatDemoScreen> {
  final TextEditingController _jobIdCtrl = TextEditingController();
  final TextEditingController _freelancerIdCtrl = TextEditingController();
  final TextEditingController _freelancerNameCtrl = TextEditingController();
  final TextEditingController _clientIdCtrl = TextEditingController();
  final TextEditingController _clientNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with demo data
    _jobIdCtrl.text = 'job-${DateTime.now().millisecondsSinceEpoch}';
    _freelancerIdCtrl.text = 'freelancer-001';
    _freelancerNameCtrl.text = 'Priya (Freelancer)';
    _clientIdCtrl.text = 'client-001';
    _clientNameCtrl.text = 'Amit (Client)';
  }

  void _openChat({required bool asFreelancer}) {
    if (_jobIdCtrl.text.isEmpty ||
        _freelancerIdCtrl.text.isEmpty ||
        _clientIdCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    // Set the user context
    final authProvider = context.read<AuthProvider>();

    // Mock the user data based on role
    if (asFreelancer) {
      authProvider.setLoginUser(
        uid: _freelancerIdCtrl.text,
        email: 'freelancer@forge.com',
      );
    } else {
      authProvider.setLoginUser(
        uid: _clientIdCtrl.text,
        email: 'client@forge.com',
      );
    }

    // Open chat with arguments
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'jobId': _jobIdCtrl.text,
        'otherUid': asFreelancer ? _clientIdCtrl.text : _freelancerIdCtrl.text,
        'otherName': asFreelancer
            ? _clientNameCtrl.text
            : _freelancerNameCtrl.text,
      },
    );
  }

  @override
  void dispose() {
    _jobIdCtrl.dispose();
    _freelancerIdCtrl.dispose();
    _freelancerNameCtrl.dispose();
    _clientIdCtrl.dispose();
    _clientNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA82323),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chat Demo - Freelancer & Client'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💬 WhatsApp-Style Chat Demo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA82323),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Configure a freelancer and client below, then open the chat as either role. Send messages back and forth in real-time!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Job Configuration
            _buildSection(
              title: 'Job Details',
              children: [
                _buildTextField(
                  controller: _jobIdCtrl,
                  label: 'Job ID',
                  hint: 'e.g., job-12345',
                ),
              ],
            ),

            // Freelancer Configuration
            _buildSection(
              title: 'Freelancer Details',
              children: [
                _buildTextField(
                  controller: _freelancerIdCtrl,
                  label: 'Freelancer ID',
                  hint: 'e.g., freelancer-001',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _freelancerNameCtrl,
                  label: 'Freelancer Name',
                  hint: 'e.g., Priya',
                ),
              ],
            ),

            // Client Configuration
            _buildSection(
              title: 'Client Details',
              children: [
                _buildTextField(
                  controller: _clientIdCtrl,
                  label: 'Client ID',
                  hint: 'e.g., client-001',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _clientNameCtrl,
                  label: 'Client Name',
                  hint: 'e.g., Amit',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openChat(asFreelancer: true),
                    icon: const Icon(Icons.person_outline),
                    label: const Text('Chat as Freelancer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA82323),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openChat(asFreelancer: false),
                    icon: const Icon(Icons.business_outlined),
                    label: const Text('Chat as Client'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D9E51),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📖 How to Test:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInstructionItem(
                    '1. Click "Chat as Freelancer" to open chat as the freelancer',
                  ),
                  _buildInstructionItem('2. Send a test message'),
                  _buildInstructionItem(
                    '3. Use device preview split-screen or use 2 devices/emulators',
                  ),
                  _buildInstructionItem(
                    '4. Click "Chat as Client" to open the same chat as the client',
                  ),
                  _buildInstructionItem(
                    '5. See messages appear in real-time like WhatsApp!',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Features List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ Chat Features:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem(
                    '✓ Real-time messaging via Firebase Firestore',
                  ),
                  _buildFeatureItem('✓ Message timestamps'),
                  _buildFeatureItem(
                    '✓ Different bubble colors for sender/receiver',
                  ),
                  _buildFeatureItem('✓ Auto-scroll to latest messages'),
                  _buildFeatureItem('✓ Clean WhatsApp-style UI'),
                  _buildFeatureItem('✓ Error handling & loading states'),
                  _buildFeatureItem('✓ Professional animations'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFA82323), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}
