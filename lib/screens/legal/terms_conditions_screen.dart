import 'package:flutter/material.dart';
import 'package:streamit_laravel/screens/legal/legal_page_scaffold.dart';

/// Terms & Conditions for a real-money skill-based game (Winzo-style).
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPageScaffold(
      title: 'Terms & Conditions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          legalParagraph(
            'Welcome to WAMIMS. By using our skill-based gaming platform you agree to these Terms & Conditions. '
            'Our platform offers games of skill where you can compete and win real cash (INR). Please read carefully.',
          ),
          legalSectionTitle('1. Eligibility'),
          legalParagraph(
            'You must be 18 years or older (or the age of majority in your jurisdiction) to play. '
            'You must be physically located in a region where skill-based real-money gaming is permitted. '
            'You are responsible for complying with your local laws.',
          ),
          legalSectionTitle('2. Skill-Based Games'),
          legalParagraph(
            'Games on WAMIMS are games of skill. Outcomes depend on your knowledge, practice, and strategy—not chance. '
            'You may participate in paid entry tournaments and win cash prizes based on your performance.',
          ),
          legalSectionTitle('3. Account & Fair Play'),
          legalParagraph(
            'You must provide accurate information. One account per person. No bots, hacks, or unfair means. '
            'We reserve the right to suspend or terminate accounts for breach of fair play or these terms.',
          ),
          legalSectionTitle('4. Deposits & Withdrawals'),
          legalParagraph(
            'Deposits and withdrawals are subject to our payment policy and applicable laws. '
            'Minimum withdrawal limits and KYC verification may apply before you can withdraw winnings.',
          ),
          legalSectionTitle('5. Responsible Gaming'),
          legalParagraph(
            'Play responsibly. We provide tools to set limits and self-exclude. If you feel you have a gambling problem, '
            'please seek help and use our responsible gaming options.',
          ),
          legalSectionTitle('6. Limitation of Liability'),
          legalParagraph(
            'We are not liable for losses beyond the amount you have deposited, except where required by law.',
          ),
          legalSectionTitle('7. Contact & Operator Details'),
          legalParagraph(
            'Operator: Aryan Raikwar. Address: Dillod, Madhya Pradesh. Email: aryanraikwar09@gmail.com, '
            'Support: babubhiya94@gmail.com. Phone: +91 7987048252. For disputes or queries, contact us at the above.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
