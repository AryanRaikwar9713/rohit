import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:streamit_laravel/utils/colors.dart';

/// Dark, Winzo-style scaffold for policy/legal pages (skill-based game look).
class LegalPageScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const LegalPageScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appScreenBackgroundDark,
      appBar: AppBar(
        title: Text(
          title,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: child,
      ),
    );
  }
}

/// Section heading on legal pages.
Widget legalSectionTitle(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        color: appColorPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    ),
  );
}

/// Body paragraph.
Widget legalParagraph(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: 13,
        height: 1.5,
      ),
    ),
  );
}
