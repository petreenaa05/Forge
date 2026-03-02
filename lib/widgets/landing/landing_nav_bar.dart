import 'package:flutter/material.dart';

class LandingNavBar extends StatelessWidget {
  const LandingNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          const Text(
            'Forge',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFFA82323), // Primary
            ),
          ),
          const Spacer(),
          if (!isMobile) ...[
            TextButton(onPressed: () {}, child: const Text('About')),
            const SizedBox(width: 8),
            TextButton(onPressed: () {}, child: const Text('Features')),
            const SizedBox(width: 8),
            TextButton(onPressed: () {}, child: const Text('How It Works')),
            const SizedBox(width: 20),
          ],
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFA82323),
              side: const BorderSide(color: Color(0xFFA82323), width: 2),
              minimumSize: const Size(110, 44),
            ),
            child: const Text('Sign Up'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA82323),
              foregroundColor: Colors.white,
              minimumSize: const Size(110, 44),
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
