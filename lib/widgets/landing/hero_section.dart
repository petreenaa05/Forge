import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  final bool isMobile;

  const HeroSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 56),
      child: isMobile
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroText(),
                SizedBox(height: 24),
                _HeroActions(),
                SizedBox(height: 28),
                _HeroIllustration(),
              ],
            )
          : const Row(
              children: [
                Expanded(child: _HeroTextAndActions()),
                SizedBox(width: 40),
                Expanded(child: _HeroIllustration()),
              ],
            ),
    );
  }
}

class _HeroTextAndActions extends StatelessWidget {
  const _HeroTextAndActions();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_HeroText(), SizedBox(height: 24), _HeroActions()],
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Empowering Women Through Skills & Mentorship',
          style: TextStyle(
            fontSize: 52,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: Color(0xFF222222),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Forge connects women learners with verified mentors to build practical skills, confidence, and a trusted support network.',
          style: TextStyle(fontSize: 17, height: 1.6, color: Color(0xFF666666)),
        ),
      ],
    );
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA82323),
            foregroundColor: Colors.white,
            minimumSize: const Size(145, 48),
          ),
          child: const Text('Get Started'),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFA82323),
            side: const BorderSide(color: Color(0xFFA82323)),
            minimumSize: const Size(145, 48),
          ),
          child: const Text('Learn More'),
        ),
      ],
    );
  }
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/hero_illustration.png',
          height: 360,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image not found
            return Container(
              height: 360,
              decoration: BoxDecoration(
                color: const Color(0xFFDED6D6).withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.groups_rounded,
                  size: 120,
                  color: Color(0xFF7D938A),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
