import 'package:flutter/material.dart';
import 'package:forge/screens/chat/support_chat_page.dart';

// =============================================================================
// Design tokens — match Forge brand
// =============================================================================
class _C {
  static const Color maroon = Color(0xFFA82323);
  static const Color maroonDark = Color(0xFF7A1818);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);
  static const Color grey = Color(0xFF555555);
  static const Color greyLight = Color(0xFF888888);
  static const Color border = Color(0xFFEEEEEE);
  static const Color bgLight = Color(0xFFFAFAFA);
  static const Color heroGrad1 = Color(0xFFFFF5F5);
  static const Color heroGrad2 = Color(0xFFFFFFFF);
}

/// Landing page — the first screen users see.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: _C.white,
          body: Column(
            children: [
              _NavBar(
                isMobile: isMobile,
                onAboutTap: () => _scrollToSection(_aboutKey),
                onFeaturesTap: () => _scrollToSection(_featuresKey),
                onHowItWorksTap: () => _scrollToSection(_howItWorksKey),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      _HeroSection(
                        isMobile: isMobile,
                        onLearnMore: () => _scrollToSection(_aboutKey),
                      ),
                      _AboutSection(key: _aboutKey, isMobile: isMobile),
                      _FeaturesSection(key: _featuresKey, isMobile: isMobile),
                      _BenefitsSection(isMobile: isMobile),
                      _HowItWorksSection(
                        key: _howItWorksKey,
                        isMobile: isMobile,
                      ),
                      const _FooterSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Floating Chatbot Button
        FloatingChatbotButton(),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  NAV BAR — taller, bigger fonts
// ═══════════════════════════════════════════════════════════════════
class _NavBar extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onAboutTap;
  final VoidCallback onFeaturesTap;
  final VoidCallback onHowItWorksTap;

  const _NavBar({
    required this.isMobile,
    required this.onAboutTap,
    required this.onFeaturesTap,
    required this.onHowItWorksTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 36),
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
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: _C.maroon,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),

          if (!isMobile) ...[
            _HoverNavLink(text: 'About', onTap: onAboutTap),
            const SizedBox(width: 12),
            _HoverNavLink(text: 'Features', onTap: onFeaturesTap),
            const SizedBox(width: 12),
            _HoverNavLink(text: 'How It Works', onTap: onHowItWorksTap),
            const SizedBox(width: 28),
          ],

          _HoverButton(
            label: 'Sign Up',
            filled: false,
            onTap: () => Navigator.pushNamed(context, '/signup'),
          ),
          const SizedBox(width: 12),

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
  final VoidCallback onTap;
  const _HoverNavLink({required this.text, required this.onTap});

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
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered
                ? _C.maroon.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: _hovered ? _C.maroon : _C.grey,
              fontWeight: _hovered ? FontWeight.w600 : FontWeight.w500,
              fontSize: 16,
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
  const _HoverButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

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
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
            decoration: BoxDecoration(
              color: widget.filled
                  ? (_hovered ? _C.maroonDark : _C.maroon)
                  : (_hovered ? _C.maroon.withValues(alpha: 0.06) : _C.white),
              border: Border.all(
                color: _C.maroon,
                width: widget.filled ? 0 : 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _hovered && widget.filled
                  ? [
                      BoxShadow(
                        color: _C.maroon.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
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
//  HERO SECTION — GSAP-style staggered entrance
// ═══════════════════════════════════════════════════════════════════
class _HeroSection extends StatefulWidget {
  final bool isMobile;
  final VoidCallback onLearnMore;
  const _HeroSection({required this.isMobile, required this.onLearnMore});

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  // Staggered animations like GSAP timeline
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _buttonsFade;
  late final Animation<double> _badgesFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    // GSAP-like stagger: title → subtitle → buttons → badges
    _titleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
          ),
        );
    _buttonsFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    );
    _badgesFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 24 : 80,
        vertical: widget.isMobile ? 56 : 96,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.heroGrad1, _C.heroGrad2],
        ),
      ),
      child: Column(
        children: [
          // Title — stagger 1
          FadeTransition(
            opacity: _titleFade,
            child: SlideTransition(
              position: _titleSlide,
              child: Text(
                'Connect. Collaborate. Grow.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: widget.isMobile ? 36 : 54,
                  fontWeight: FontWeight.w900,
                  color: _C.black,
                  height: 1.15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Subtitle — stagger 2
          FadeTransition(
            opacity: _subtitleFade,
            child: SlideTransition(
              position: _subtitleSlide,
              child: Text(
                'A women-only skilled services marketplace built on verification, reputation, and structured workflows.\nSecure your identity, showcase your skills, and build professional credibility.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: widget.isMobile ? 16 : 20,
                  color: const Color(0xFF666666),
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Buttons — stagger 3
          FadeTransition(
            opacity: _buttonsFade,
            child: Wrap(
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
                  onTap: widget.onLearnMore,
                ),
              ],
            ),
          ),
          const SizedBox(height: 44),

          // Trust badges — stagger 4
          FadeTransition(
            opacity: _badgesFade,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 36,
              runSpacing: 12,
              children: const [
                _TrustBadge(
                  icon: Icons.verified_user,
                  text: 'Identity Verified',
                ),
                _TrustBadge(
                  icon: Icons.workspace_premium_rounded,
                  text: 'Women-Only Platform',
                ),
                _TrustBadge(
                  icon: Icons.shield_rounded,
                  text: 'Secure Workflow',
                ),
              ],
            ),
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
        Icon(icon, size: 20, color: _C.maroon),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _C.grey,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SCROLL-TRIGGERED FADE-IN  (GSAP-like "scrollTrigger")
// ═══════════════════════════════════════════════════════════════════
class _ScrollFadeIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;

  const _ScrollFadeIn({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.slideOffset = const Offset(0, 40),
  });

  @override
  State<_ScrollFadeIn> createState() => _ScrollFadeInState();
}

class _ScrollFadeInState extends State<_ScrollFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onVisibility(bool visible) {
    if (visible && !_triggered) {
      _triggered = true;
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _VisibilityDetector(
      onVisibilityChanged: _onVisibility,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Opacity(
          opacity: _fade.value,
          child: Transform.translate(offset: _slide.value, child: child),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Simple visibility detector using LayoutBuilder + scroll position.
class _VisibilityDetector extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool> onVisibilityChanged;
  const _VisibilityDetector({
    required this.child,
    required this.onVisibilityChanged,
  });

  @override
  State<_VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<_VisibilityDetector> {
  final GlobalKey _key = GlobalKey();
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (!mounted || _visible) return;
    final ro = _key.currentContext?.findRenderObject() as RenderBox?;
    if (ro == null || !ro.attached) {
      // Retry next frame
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
      return;
    }
    final pos = ro.localToGlobal(Offset.zero);
    final screenH = MediaQuery.of(context).size.height;
    if (pos.dy < screenH + 50) {
      _visible = true;
      widget.onVisibilityChanged(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        _check();
        return false;
      },
      child: SizedBox(key: _key, child: widget.child),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ABOUT SECTION — Company mission and vision
// ═══════════════════════════════════════════════════════════════════
class _AboutSection extends StatelessWidget {
  final bool isMobile;
  const _AboutSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 72,
      ),
      color: _C.white,
      child: Column(
        children: [
          _ScrollFadeIn(
            child: const Text(
              'Built for Women Professionals',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: _C.black,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 100),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  Text(
                    'Forge is a women-only skilled services marketplace where verified professionals connect with clients through structured, reputation-driven workflows.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.w600,
                      color: _C.black,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Every user is verified through Aadhaar-based authentication, ensuring identity accountability and safety. Women professionals in technical and service sectors can build their reputation, manage availability, and access booking opportunities in a secure environment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 17,
                      color: _C.grey,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'From job confirmation to payment tracking, every interaction follows a structured lifecycle designed for clarity, trust, and professional growth.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 17,
                      color: _C.grey,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Mission & Vision Cards
          _ScrollFadeIn(
            delay: const Duration(milliseconds: 200),
            child: isMobile
                ? Column(
                    children: const [
                      _AboutCard(
                        icon: Icons.workspace_premium_rounded,
                        title: 'Verification First',
                        description:
                            'Every user undergoes Aadhaar-based identity verification, creating a secure and accountable professional network where trust is built into the system.',
                      ),
                      SizedBox(height: 20),
                      _AboutCard(
                        icon: Icons.equalizer_rounded,
                        title: 'Reputation Driven',
                        description:
                            'Women professionals build their reputation through structured bookings, ratings, and completed jobs—making quality and reliability measurable and rewarding.',
                      ),
                    ],
                  )
                : Row(
                    children: const [
                      Expanded(
                        child: _AboutCard(
                          icon: Icons.workspace_premium_rounded,
                          title: 'Verification First',
                          description:
                              'Every user undergoes Aadhaar-based identity verification, creating a secure and accountable professional network where trust is built into the system.',
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: _AboutCard(
                          icon: Icons.equalizer_rounded,
                          title: 'Reputation Driven',
                          description:
                              'Women professionals build their reputation through structured bookings, ratings, and completed jobs—making quality and reliability measurable and rewarding.',
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  const _AboutCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  State<_AboutCard> createState() => _AboutCardState();
}

class _AboutCardState extends State<_AboutCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _hovered ? _C.maroon.withValues(alpha: 0.03) : _C.bgLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? _C.maroon : _C.border,
            width: _hovered ? 2 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: _C.maroon.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _hovered ? _C.maroon : _C.maroon.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                color: _hovered ? _C.white : _C.maroon,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _hovered ? _C.maroon : _C.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 15, color: _C.grey, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  FEATURES SECTION — staggered scroll-triggered cards
// ═══════════════════════════════════════════════════════════════════
class _FeaturesSection extends StatelessWidget {
  final bool isMobile;
  const _FeaturesSection({super.key, required this.isMobile});

  static const _features = [
    _FeatureData(
      icon: Icons.verified_user_rounded,
      title: 'Aadhaar Verification',
      description:
          'Every professional verified through government-issued identity. Build trust through authentic credentials in a secure ecosystem.',
    ),
    _FeatureData(
      icon: Icons.stars_rounded,
      title: 'Reputation & Ratings',
      description:
          'Earn stars through quality work. Your ratings drive visibility and booking opportunities. Build professional credibility over time.',
    ),
    _FeatureData(
      icon: Icons.category_rounded,
      title: 'Smart Discovery',
      description:
          'Browse skilled professionals by category, rating, availability, and price. Find perfect matches for your service needs.',
    ),
    _FeatureData(
      icon: Icons.check_circle_outline_rounded,
      title: 'Structured Workflow',
      description:
          'Clear booking lifecycle: request → confirm → in-progress → complete. Track every job status in real-time.',
    ),
    _FeatureData(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Secure In-App Chat',
      description:
          'Communicate directly without sharing personal details. Coordinate jobs, discuss details, send updates safely.',
    ),
    _FeatureData(
      icon: Icons.shield_rounded,
      title: 'Safe & Secure',
      description:
          'Women-only platform with verified professionals. Payment tracking, dispute resolution, and safety features built-in.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 72,
      ),
      color: _C.bgLight,
      child: Column(
        children: [
          const Text(
            'Powerful Features',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: _C.black,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Everything you need to work safely, professionally, and successfully.',
            style: TextStyle(fontSize: 16, color: _C.greyLight),
          ),
          const SizedBox(height: 44),
          isMobile
              ? Column(
                  children: List.generate(
                    _features.length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _FeatureCard(data: _features[i]),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 28,
                    crossAxisSpacing: 24,
                    childAspectRatio: 1.2,
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
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? _C.maroon : _C.border,
            width: _hovered ? 2 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: _C.maroon.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: _C.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _hovered ? _C.maroon : _C.maroon.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                widget.data.icon,
                color: _hovered ? _C.white : _C.maroon,
                size: 26,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              widget.data.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _hovered ? _C.maroon : _C.black,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              widget.data.description,
              style: const TextStyle(fontSize: 15, color: _C.grey, height: 1.6),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  BENEFITS SECTION — why choose Forge
// ═══════════════════════════════════════════════════════════════════
class _BenefitsSection extends StatelessWidget {
  final bool isMobile;
  const _BenefitsSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 72,
      ),
      color: _C.maroon.withValues(alpha: 0.05),
      child: Column(
        children: [
          _ScrollFadeIn(
            child: const Text(
              'Why Choose Forge?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: _C.black,
              ),
            ),
          ),
          const SizedBox(height: 44),
          isMobile
              ? Column(
                  children: const [
                    _BenefitTile(
                      icon: Icons.favorite_border_rounded,
                      title: 'Women-First Community',
                      description:
                          'A safe, verified network built exclusively for women professionals. Connect with peers who understand your needs.',
                    ),
                    SizedBox(height: 24),
                    _BenefitTile(
                      icon: Icons.trending_up_rounded,
                      title: 'Grow Your Career',
                      description:
                          'Build income opportunities and professional reputation. Track earnings, get ratings, and expand your client base.',
                    ),
                    SizedBox(height: 24),
                    _BenefitTile(
                      icon: Icons.security_rounded,
                      title: 'Secure & Transparent',
                      description:
                          'Clear pricing, verified clients, in-app payments, and dispute resolution. Know exactly what to expect.',
                    ),
                  ],
                )
              : Row(
                  children: const [
                    Expanded(
                      child: _BenefitTile(
                        icon: Icons.favorite_border_rounded,
                        title: 'Women-First Community',
                        description:
                            'A safe, verified network built exclusively for women professionals. Connect with peers who understand your needs.',
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: _BenefitTile(
                        icon: Icons.trending_up_rounded,
                        title: 'Grow Your Career',
                        description:
                            'Build income opportunities and professional reputation. Track earnings, get ratings, and expand your client base.',
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: _BenefitTile(
                        icon: Icons.security_rounded,
                        title: 'Secure & Transparent',
                        description:
                            'Clear pricing, verified clients, in-app payments, and dispute resolution. Know exactly what to expect.',
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  const _BenefitTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  State<_BenefitTile> createState() => _BenefitTileState();
}

class _BenefitTileState extends State<_BenefitTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _hovered ? _C.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? _C.maroon : _C.border,
            width: _hovered ? 2 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: _C.maroon.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _hovered ? _C.maroon : _C.maroon.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                widget.icon,
                color: _hovered ? _C.white : _C.maroon,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: _hovered ? _C.maroon : _C.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 15, color: _C.grey, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  HOW IT WORKS SECTION — staggered scroll-triggered step tiles
// ═══════════════════════════════════════════════════════════════════
class _HowItWorksSection extends StatelessWidget {
  final bool isMobile;
  const _HowItWorksSection({super.key, required this.isMobile});

  static const _steps = [
    _StepData(
      number: '1',
      title: 'Join & Get Verified',
      subtitle:
          'Sign up with email and complete Aadhaar verification. Takes 5 minutes—one-time setup.',
    ),
    _StepData(
      number: '2',
      title: 'Choose Your Path',
      subtitle:
          'Offer services as a freelancer OR hire professionals as a client. Switch roles anytime.',
    ),
    _StepData(
      number: '3',
      title: 'Browse, Request & Confirm',
      subtitle:
          'Find professionals by skill, rate, & availability. Send requests. Discuss & confirm details in-app.',
    ),
    _StepData(
      number: '4',
      title: 'Track & Collaborate',
      subtitle:
          'Work progresses from confirmed → in-progress → complete. Use in-app messaging for coordination.',
    ),
    _StepData(
      number: '5',
      title: 'Rate & Build Reputation',
      subtitle:
          'Complete jobs successfully. Leave ratings & reviews. Build your professional profile & unlock opportunities.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 80,
        vertical: 72,
      ),
      color: _C.white,
      child: Column(
        children: [
          const Text(
            'Getting Started is Simple',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: _C.black,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Join the verified network of professionals and start earning or hiring in minutes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: _C.greyLight),
          ),
          const SizedBox(height: 44),
          isMobile
              ? Column(
                  children: List.generate(
                    _steps.length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _StepTile(data: _steps[i]),
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 28,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _steps.length,
                  itemBuilder: (_, i) => _StepTile(data: _steps[i]),
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
  const _StepData({
    required this.number,
    required this.title,
    required this.subtitle,
  });
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
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: _hovered ? _C.maroonDark : _C.maroon,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _C.maroon.withValues(alpha: _hovered ? 0.35 : 0.15),
                    blurRadius: _hovered ? 18 : 10,
                    offset: Offset(0, _hovered ? 6 : 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                widget.data.number,
                style: const TextStyle(
                  color: _C.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.data.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _hovered ? _C.maroon : _C.black,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                widget.data.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: _C.grey,
                  height: 1.5,
                ),
                maxLines: null,
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 36),
      color: _C.black,
      child: const Text(
        '© 2026 Forge — Services Marketplace. All rights reserved.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF999999), fontSize: 14),
      ),
    );
  }
}
