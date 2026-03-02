import 'package:flutter/material.dart';
import 'feature_card.dart';

class FeaturesSection extends StatelessWidget {
  final bool isMobile;

  const FeaturesSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      const FeatureCard(
        icon: Icons.verified_user_rounded,
        title: 'Verified Mentorship',
        subtitle: 'Trusted and verified mentors for practical skill-building.',
      ),
      const FeatureCard(
        icon: Icons.shield_rounded,
        title: 'Secure Identity Verification',
        subtitle: 'Safety-first onboarding and role-based trust signals.',
      ),
      const FeatureCard(
        icon: Icons.group_work_rounded,
        title: 'Community Skill Exchange',
        subtitle: 'Collaborative learning, support, and growth opportunities.',
      ),
    ];

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(28, 62, 28, 62),
      child: Column(
        children: [
          const Text(
            'Features',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Text(
            'Designed for trust, growth, and women-led mentorship.',
            style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 30),
          isMobile
              ? Column(
                  children: [
                    for (final card in cards) ...[
                      card,
                      const SizedBox(height: 16),
                    ],
                  ],
                )
              : Row(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      Expanded(child: cards[i]),
                      if (i != cards.length - 1) const SizedBox(width: 16),
                    ],
                  ],
                ),
        ],
      ),
    );
  }
}
