import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contact Us for skill-based game support – real business details for PayUMoney/gateway compliance.
class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static const String supportEmail = 'aryanraikwar09@gmail.com';
  static const String alternateEmail = 'babubhiya94@gmail.com';
  static const String supportPhone = '+91 7987048252';
  static const String contactName = 'Aryan Raikwar';
  static const String address = 'Dillod, Madhya Pradesh';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appScreenBackgroundDark,
      appBar: AppBar(
        title: Text(
          'Contact Us',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: appScreenBackgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "We're here to help with your skill gaming experience—queries, withdrawals, or fair play issues.",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            24.height,
            const _ContactTile(
              icon: Icons.person_outline_rounded,
              title: 'Contact Person',
              subtitle: contactName,
            ),
            16.height,
            _ContactTile(
              icon: Icons.email_outlined,
              title: 'Email (Primary)',
              subtitle: supportEmail,
              onTap: () => _launchUrl('mailto:$supportEmail'),
            ),
            16.height,
            _ContactTile(
              icon: Icons.alternate_email_rounded,
              title: 'Email (Support)',
              subtitle: alternateEmail,
              onTap: () => _launchUrl('mailto:$alternateEmail'),
            ),
            16.height,
            _ContactTile(
              icon: Icons.phone_outlined,
              title: 'Phone',
              subtitle: supportPhone,
              onTap: () => _launchUrl('tel:$supportPhone'),
            ),
            16.height,
            const _ContactTile(
              icon: Icons.location_on_outlined,
              title: 'Address',
              subtitle: address,
            ),
            24.height,
            Text(
              'Response time: We aim to respond within 24–48 hours on working days.',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
            16.height,
            Text(
              'For withdrawal or KYC issues, please include your registered mobile/email and user ID in your message. '
              'You can reach us at $supportEmail or $supportPhone.',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        toast('Could not open link');
      }
    } catch (e) {
      toast('Could not open link');
    }
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appColorPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: appColorPrimary, size: 24),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  4.height,
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
