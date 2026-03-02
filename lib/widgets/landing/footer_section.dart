import 'package:flutter/material.dart';

class LandingFooterSection extends StatelessWidget {
  const LandingFooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
      ),
      child: const Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 10,
        children: [
          Text('Forge © 2026', style: TextStyle(color: Color(0xFF666666))),
          Text('Privacy Policy', style: TextStyle(color: Color(0xFF666666))),
          Text('Terms', style: TextStyle(color: Color(0xFF666666))),
        ],
      ),
    );
  }
}
