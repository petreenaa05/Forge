import 'package:flutter/material.dart';

class HowItWorksSection extends StatelessWidget {
  final bool isMobile;

  const HowItWorksSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 62, 28, 62),
      child: Column(
        children: [
          const Text(
            'How It Works',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 26),
          isMobile
              ? const Column(
                  children: [
                    StepTile(number: '1', title: 'Sign Up & Verify'),
                    SizedBox(height: 12),
                    StepTile(number: '2', title: 'Choose Your Role'),
                    SizedBox(height: 12),
                    StepTile(number: '3', title: 'Connect & Grow'),
                  ],
                )
              : const Row(
                  children: [
                    Expanded(
                      child: StepTile(number: '1', title: 'Sign Up & Verify'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: StepTile(number: '2', title: 'Choose Your Role'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: StepTile(number: '3', title: 'Connect & Grow'),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class StepTile extends StatelessWidget {
  final String number;
  final String title;

  const StepTile({super.key, required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFA82323), // Primary
            child: Text(number, style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
