import 'package:flutter/material.dart';
import 'package:streamit_laravel/screens/legal/legal_page_scaffold.dart';

/// Cancellation Policy for a real-money skill-based game (Winzo-style).
class CancellationPolicyScreen extends StatelessWidget {
  const CancellationPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPageScaffold(
      title: 'Cancellation Policy',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          legalParagraph(
            'This Cancellation Policy applies to contests, subscriptions, and transactions on the WAMIMS skill-based gaming platform.',
          ),
          legalSectionTitle('1. Contest / Tournament Entry'),
          legalParagraph(
            'Once you have entered a paid contest or tournament, your entry cannot be cancelled and the entry fee is non-refundable. '
            'If a contest is cancelled by us (e.g. insufficient participants), your entry fee will be credited back to your wallet.',
          ),
          legalSectionTitle('2. Subscription Cancellation'),
          legalParagraph(
            'If you have a paid subscription (e.g. premium membership), you may cancel before the next billing cycle. '
            'No refund will be provided for the current period; access continues until the end of that period.',
          ),
          legalSectionTitle('3. Withdrawal Cancellation'),
          legalParagraph(
            'You may cancel a withdrawal request before it is processed. Once processed, it cannot be cancelled.',
          ),
          legalSectionTitle('4. Account Closure'),
          legalParagraph(
            'You may close your account at any time. Withdrawable balance must be withdrawn before closure or as per our withdrawal policy. '
            'We may close or suspend accounts for violation of Terms or fair play.',
          ),
          legalSectionTitle('5. Contact Us'),
          legalParagraph(
            'For any cancellation request, contact: Aryan Raikwar, Email: aryanraikwar09@gmail.com or babubhiya94@gmail.com, '
            'Phone: +91 7987048252, Address: Dillod, Madhya Pradesh. Provide your user ID and details. '
            'We will process as per this policy. All transactions are in INR.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
