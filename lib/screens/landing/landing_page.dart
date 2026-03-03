import 'package:flutter/material.dart';

/// Landing page — the first screen users see.
/// Showcases Forge and provides Sign In / Sign Up entry points.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const Color _primary = Color(0xFFA82323);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Nav Bar ───────────────────────────────────
          _NavBar(isMobile: isMobile),

          // ── Body ──────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _HeroSection(isMobile: isMobile),
                  _FeaturesSection(isMobile: isMobile),
                  _HowItWorksSection(isMobile: isMobile),
                  const _FooterSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  NAV BAR
// ═══════════════════════════════════════════════════════════════════
class _NavBar extends StatelessWidget {
  final bool isMobile;
  const _NavBar({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          // Logo
          const Text(
            'Forge',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFFA82323),
              letterSpacing: 1,
            ),
          ),
          const Spacer(),

          // Nav links (desktop only)
          if (!isMobile) ...[
            _navLink('About'),
            const SizedBox(width: 8),
            _navLink('Features'),
            const SizedBox(width: 8),
            _navLink('How It Works'),
            const SizedBox(width: 24),
          ],

          // Sign Up button
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFA82323),
              side: const BorderSide(color: Color(0xFFA82323), width: 2),
              minimumSize: const Size(100, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),

          // Sign In button
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA82323),
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _navLink(String text) {
    return TextButton(
      onPressed: () {},
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF555555),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  HERO SECTION
// ═══════════════════════════════════════════════════════════════════
class _HeroSection extends StatelessWidget {
  final bool isMobile;
  const _HeroSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: isMobile ? 48 : 80,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF5F5), Color(0xFFFFFFFF)],
        ),
      ),
      child: Column(
        children: [
          // Tagline
          Text(
            'Find Trusted Professionals\nNear You',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1A1A1A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Forge connects you with verified, skilled service providers.\nBook with confidence — verified via Aadhaar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 15 : 18,
              color: const Color(0xFF666666),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 36),

          // CTA Buttons
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                icon: const Icon(Icons.person_add_rounded, size: 20),
                label: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA82323),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(180, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_circle_outline, size: 20),
                label: const Text(
                  'Learn More',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFA82323),
                  side: const BorderSide(color: Color(0xFFA82323), width: 2),
                  minimumSize: const Size(180, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Trust badges
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 32,
            runSpacing: 12,
            children: const [
              _TrustBadge(icon: Icons.verified_user, text: 'Aadhaar Verified'),
              _TrustBadge(icon: Icons.star_rounded, text: 'Top Rated Pros'),
              _TrustBadge(icon: Icons.security, text: 'Safe & Secure'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TrustBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFFA82323)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  FEATURES SECTION
// ═══════════════════════════════════════════════════════════════════
class _FeaturesSection extends StatelessWidget {
  final bool isMobile;
  const _FeaturesSection({required this.isMobile});

  static const _features = [
    _FeatureData(
      icon: Icons.badge_rounded,
      title: 'Aadhaar Verified',
      description: 'Every professional is verified with Aadhaar for trust and safety.',
    ),
    _FeatureData(
      icon: Icons.swap_horiz_rounded,
      title: 'Switch Roles Anytime',
      description: 'Be a freelancer and client both — switch with a single tap.',
    ),
    _FeatureData(
      icon: Icons.chat_rounded,
      title: 'In-App Chat',
      description: 'Communicate directly with your service provider before and during jobs.',
    ),
    _FeatureData(
      icon: Icons.star_rounded,
      title: 'Ratings & Reviews',
      description: 'Make informed decisions with real ratings from real customers.',
    ),
    _FeatureData(
      icon: Icons.calendar_month_rounded,
      title: 'Easy Booking',
      description: 'Pick a date, time, and professional — booking is just a few taps away.',
    ),
    _FeatureData(
      icon: Icons.location_on_rounded,
      title: 'Local Professionals',
      description: 'Find skilled workers near your location, available when you need them.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 64,
      ),
      color: const Color(0xFFFAFAFA),
      child: Column(
        children: [
          const Text(
            'Why Choose Forge?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Built for trust, speed, and simplicity.',
            style: TextStyle(fontSize: 15, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: isMobile ? 3.2 : 1.6,
            ),
            itemCount: _features.length,
            itemBuilder: (_, i) => _FeatureCard(data: _features[i]),
          ),
        ],
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;
  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFA82323).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: const Color(0xFFA82323), size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  HOW IT WORKS SECTION
// ═══════════════════════════════════════════════════════════════════
class _HowItWorksSection extends StatelessWidget {
  final bool isMobile;
  const _HowItWorksSection({required this.isMobile});

  static const _steps = [
    _StepData(number: '1', title: 'Sign Up with Aadhaar', subtitle: 'Quick, verified identity check.'),
    _StepData(number: '2', title: 'Choose Your Role', subtitle: 'Offer services or find professionals.'),
    _StepData(number: '3', title: 'Book or Get Booked', subtitle: 'Connect, chat, and complete jobs.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 64,
      ),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'How It Works',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 40),
          isMobile
              ? Column(
                  children: _steps
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _StepTile(data: s),
                          ))
                      .toList(),
                )
              : Row(
                  children: _steps
                      .map((s) => Expanded(child: _StepTile(data: s)))
                      .toList(),
                ),
        ],
      ),
    );
  }
}

class _StepData {
  final String number;
  final String title;
  final String subtitle;
  const _StepData({required this.number, required this.title, required this.subtitle});
}

class _StepTile extends StatelessWidget {
  final _StepData data;
  const _StepTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFA82323),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            data.number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2D2D),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          data.subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF888888),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  FOOTER
// ═══════════════════════════════════════════════════════════════════
class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 28),
      color: const Color(0xFF1A1A1A),
      child: const Text(
        '© 2026 Forge — Services Marketplace. All rights reserved.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF999999), fontSize: 13),
      ),
    );
  }
}
