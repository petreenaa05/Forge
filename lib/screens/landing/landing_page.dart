import 'package:flutter/material.dart';

// =============================================================================
// Design tokens — match Forge brand
// =============================================================================
class _C {
  static const Color maroon     = Color(0xFFA82323);
  static const Color maroonDark = Color(0xFF7A1818);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color black      = Color(0xFF1A1A1A);
  static const Color grey       = Color(0xFF555555);
  static const Color greyLight  = Color(0xFF888888);
  static const Color border     = Color(0xFFEEEEEE);
  static const Color bgLight    = Color(0xFFFAFAFA);
  static const Color heroGrad1  = Color(0xFFFFF5F5);
  static const Color heroGrad2  = Color(0xFFFFFFFF);
}

/// Landing page — the first screen users see.
/// Showcases Forge and provides Sign In / Sign Up entry points.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Scaffold(
      backgroundColor: _C.white,
      body: Column(
        children: [
          _NavBar(isMobile: isMobile),
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
//  NAV BAR — with hover on links and buttons
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
        color: _C.white,
        border: Border(bottom: BorderSide(color: _C.border)),
      ),
      child: Row(
        children: [
          // Logo
          const Text(
            'Forge',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _C.maroon,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),

          // Nav links (desktop only)
          if (!isMobile) ...[
            const _HoverNavLink(text: 'About'),
            const SizedBox(width: 8),
            const _HoverNavLink(text: 'Features'),
            const SizedBox(width: 8),
            const _HoverNavLink(text: 'How It Works'),
            const SizedBox(width: 24),
          ],

          // Sign Up button
          _HoverButton(
            label: 'Sign Up',
            filled: false,
            onTap: () => Navigator.pushNamed(context, '/signup'),
          ),
          const SizedBox(width: 10),

          // Sign In button
          _HoverButton(
            label: 'Sign In',
            filled: true,
            onTap: () => Navigator.pushNamed(context, '/login'),
          ),
        ],
      ),
    );
  }
}

// ── Hover Nav Link ──────────────────────────────────────────────────
class _HoverNavLink extends StatefulWidget {
  final String text;
  const _HoverNavLink({required this.text});

  @override
  State<_HoverNavLink> createState() => _HoverNavLinkState();
}

class _HoverNavLinkState extends State<_HoverNavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? _C.maroon.withValues(alpha: 0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: _hovered ? _C.maroon : _C.grey,
              fontWeight: _hovered ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hover Button (filled or outlined) ───────────────────────────────
class _HoverButton extends StatefulWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _HoverButton({required this.label, required this.filled, required this.onTap});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
            decoration: BoxDecoration(
              color: widget.filled
                  ? (_hovered ? _C.maroonDark : _C.maroon)
                  : (_hovered ? _C.maroon.withValues(alpha: 0.06) : _C.white),
              border: Border.all(
                color: _C.maroon,
                width: widget.filled ? 0 : 2,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: _hovered && widget.filled
                  ? [BoxShadow(color: _C.maroon.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: widget.filled ? _C.white : _C.maroon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  HERO SECTION — with animated entrance
// ═══════════════════════════════════════════════════════════════════
class _HeroSection extends StatefulWidget {
  final bool isMobile;
  const _HeroSection({required this.isMobile});

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 24 : 80,
        vertical: widget.isMobile ? 48 : 80,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.heroGrad1, _C.heroGrad2],
        ),
      ),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Column(
            children: [
              Text(
                'Find Trusted Professionals\nNear You',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: widget.isMobile ? 32 : 48,
                  fontWeight: FontWeight.w900,
                  color: _C.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Forge connects you with verified, skilled service providers.\nBook with confidence — verified via Aadhaar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: widget.isMobile ? 15 : 18,
                  color: const Color(0xFF666666),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 36),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  _HoverButton(
                    label: '  Get Started  ',
                    filled: true,
                    onTap: () => Navigator.pushNamed(context, '/signup'),
                  ),
                  _HoverButton(
                    label: '  Learn More  ',
                    filled: false,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 40),

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
        ),
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
        Icon(icon, size: 18, color: _C.maroon),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _C.grey,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  FEATURES SECTION — with hover cards
// ═══════════════════════════════════════════════════════════════════
class _FeaturesSection extends StatelessWidget {
  final bool isMobile;
  const _FeaturesSection({required this.isMobile});

  static const _features = [
    _FeatureData(icon: Icons.badge_rounded, title: 'Aadhaar Verified',
        description: 'Every professional is verified with Aadhaar for trust and safety.'),
    _FeatureData(icon: Icons.swap_horiz_rounded, title: 'Switch Roles Anytime',
        description: 'Be a freelancer and client both — switch with a single tap.'),
    _FeatureData(icon: Icons.chat_rounded, title: 'In-App Chat',
        description: 'Communicate directly with your service provider before and during jobs.'),
    _FeatureData(icon: Icons.star_rounded, title: 'Ratings & Reviews',
        description: 'Make informed decisions with real ratings from real customers.'),
    _FeatureData(icon: Icons.calendar_month_rounded, title: 'Easy Booking',
        description: 'Pick a date, time, and professional — booking is just a few taps away.'),
    _FeatureData(icon: Icons.location_on_rounded, title: 'Local Professionals',
        description: 'Find skilled workers near your location, available when you need them.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 64,
      ),
      color: _C.bgLight,
      child: Column(
        children: [
          const Text(
            'Why Choose Forge?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _C.black),
          ),
          const SizedBox(height: 12),
          const Text(
            'Built for trust, speed, and simplicity.',
            style: TextStyle(fontSize: 15, color: _C.greyLight),
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
  const _FeatureData({required this.icon, required this.title, required this.description});
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData data;
  const _FeatureCard({required this.data});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hovered ? _C.maroon : _C.border),
          boxShadow: _hovered
              ? [BoxShadow(color: _C.maroon.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 6))]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _hovered ? _C.maroon : _C.maroon.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.data.icon,
                  color: _hovered ? _C.white : _C.maroon, size: 22),
            ),
            const SizedBox(height: 16),
            Text(
              widget.data.title,
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: _hovered ? _C.maroon : const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.data.description,
              style: const TextStyle(fontSize: 13, color: _C.greyLight, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  HOW IT WORKS SECTION — with hover step tiles
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
      color: _C.white,
      child: Column(
        children: [
          const Text(
            'How It Works',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _C.black),
          ),
          const SizedBox(height: 40),
          isMobile
              ? Column(
                  children: _steps.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _StepTile(data: s),
                  )).toList(),
                )
              : Row(
                  children: _steps.map((s) => Expanded(child: _StepTile(data: s))).toList(),
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

class _StepTile extends StatefulWidget {
  final _StepData data;
  const _StepTile({required this.data});

  @override
  State<_StepTile> createState() => _StepTileState();
}

class _StepTileState extends State<_StepTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: _hovered ? _C.maroonDark : _C.maroon,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _hovered
                    ? [BoxShadow(color: _C.maroon.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                widget.data.number,
                style: const TextStyle(
                  color: _C.white, fontSize: 24, fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.data.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: _hovered ? _C.maroon : const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.data.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _C.greyLight),
            ),
          ],
        ),
      ),
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
      color: _C.black,
      child: const Text(
        '© 2026 Forge — Services Marketplace. All rights reserved.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF999999), fontSize: 13),
      ),
    );
  }
}
