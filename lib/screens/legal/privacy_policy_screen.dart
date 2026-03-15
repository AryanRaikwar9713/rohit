import 'package:flutter/material.dart';
import 'package:streamit_laravel/screens/legal/legal_page_scaffold.dart';

/// Privacy Policy for a real-money skill-based game (Winzo-style).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPageScaffold(
      title: 'Privacy Policy',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          legalParagraph(
            'This Privacy Policy applies to the WAMIMS skill-based gaming platform ("Platform") operated from India. '
            'We are committed to protecting your personal information when you play skill games, '
            'participate in tournaments, or use any real-money (INR) features.',
          ),
          legalSectionTitle('1. Information We Collect'),
          legalParagraph(
            'We collect information you provide (name, email, phone, payment details for withdrawals), '
            'device information, game play data, and usage patterns. This helps us run games fairly, '
            'process winnings, and improve the experience.',
          ),
          legalSectionTitle('2. How We Use Your Information'),
          legalParagraph(
            'Your data is used to operate the skill games, verify your identity, process deposits and withdrawals, '
            'send transactional and promotional communications (with your consent), prevent fraud, and comply with law.',
          ),
          legalSectionTitle('3. Sharing of Information'),
          legalParagraph(
            'We may share information with payment processors, cloud providers, and law enforcement when required. '
            'We do not sell your personal data to third parties for marketing.',
          ),
          legalSectionTitle('4. Data Security'),
          legalParagraph(
            'We use industry-standard security measures to protect your data and financial transactions.',
          ),
          legalSectionTitle('5. Your Rights'),
          legalParagraph(
            'You may access, correct, or request deletion of your data. You can opt out of marketing. '
            'Contact us for any privacy requests.',
          ),
          legalSectionTitle('6. Contact for Privacy'),
          legalParagraph(
            'For privacy-related queries or requests, contact: Aryan Raikwar, Email: aryanraikwar09@gmail.com, '
            'Phone: +91 7987048252, Address: Dillod, Madhya Pradesh.',
          ),
          legalSectionTitle('7. Updates'),
          legalParagraph(
            'We may update this policy. Continued use of the Platform after changes means you accept the updated policy.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
