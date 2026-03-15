import 'package:flutter/material.dart';
import 'package:streamit_laravel/screens/legal/legal_page_scaffold.dart';

/// Refund Policy for a real-money skill-based game (Winzo-style).
class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPageScaffold(
      title: 'Refund Policy',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          legalParagraph(
            'This Refund Policy explains when and how we process refunds on the WAMIMS skill-based gaming platform.',
          ),
          legalSectionTitle('1. Entry Fees & Contest Participation'),
          legalParagraph(
            'Once you pay an entry fee and join a contest or tournament, that fee is non-refundable. '
            'The prize pool is distributed to winners as per the contest rules. No refund is provided for losing or not completing a game.',
          ),
          legalSectionTitle('2. Unused Wallet Balance'),
          legalParagraph(
            'Unused balance in your wallet may be eligible for withdrawal subject to our Withdrawal Policy and KYC. '
            'We do not offer automatic refunds of unused balance to the original payment method except in exceptional cases (e.g. duplicate charge).',
          ),
          legalSectionTitle('3. Technical Errors'),
          legalParagraph(
            'If a technical error on our side results in an incorrect charge or failed game that you did not participate in, '
            'we may credit your account or refund the amount. You must report such issues to support within 7 days.',
          ),
          legalSectionTitle('4. Chargebacks'),
          legalParagraph(
            'Disputing a charge with your bank without contacting us first may result in account suspension and recovery action. '
            'Please contact us for any billing issues.',
          ),
          legalSectionTitle('5. Contact for Refunds'),
          legalParagraph(
            'For any refund request, contact: Aryan Raikwar, Email: aryanraikwar09@gmail.com or babubhiya94@gmail.com, '
            'Phone: +91 7987048252, Address: Dillod, Madhya Pradesh. Provide your user ID, transaction ID, and reason. '
            'We will review and respond as per this policy. All amounts are in INR.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
