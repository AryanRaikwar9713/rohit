import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/utils/colors.dart';

/// Winzo-style landing: presents the app as a real-money skill-based game.
class SkillGameLandingScreen extends StatelessWidget {
  const SkillGameLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a0a0a),
              Color(0xFF0d0505),
              appScreenBackgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // Hero
                Text(
                  'PLAY SKILL GAMES.\nWIN REAL CASH.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
                12.height,
                Text(
                  'Test your skills. Compete in tournaments. Win real cash (INR) and withdraw to your account. WAMIMS – skill-based gaming.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: appColorPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                32.height,
                // Feature cards
                const _FeatureCard(
                  icon: Icons.emoji_events_rounded,
                  title: 'Skill-Based Games',
                  subtitle: 'Win based on your talent—not luck. Fair play, real competition.',
                ),
                16.height,
                const _FeatureCard(
                  icon: Icons.payments_rounded,
                  title: 'Real Cash Prizes (INR)',
                  subtitle: 'Enter tournaments, top the leaderboard, and withdraw your winnings in INR.',
                ),
                16.height,
                const _FeatureCard(
                  icon: Icons.verified_user_rounded,
                  title: 'Safe & Secure',
                  subtitle: 'Secure payments, KYC verification, and responsible gaming tools.',
                ),
                24.height,
                Text(
                  'Eligibility: 18+ only. Play responsibly. Subject to local laws.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                16.height,
                OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: appColorPrimary,
                    side: const BorderSide(color: appColorPrimary),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  child: Text('Continue', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
                24.height,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: appColorPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: appColorPrimary, size: 28),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                4.height,
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
