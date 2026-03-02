import 'package:flutter/material.dart';
import '../../widgets/landing/landing_nav_bar.dart';
import '../../widgets/landing/hero_section.dart';
import '../../widgets/landing/features_section.dart';
import '../../widgets/landing/how_it_works_section.dart';
import '../../widgets/landing/footer_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const LandingNavBar(),
            HeroSection(isMobile: isMobile),
            FeaturesSection(isMobile: isMobile),
            HowItWorksSection(isMobile: isMobile),
            const LandingFooterSection(),
          ],
        ),
      ),
    );
  }
}
