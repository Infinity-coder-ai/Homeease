import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import 'report_problem_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const supportEmail = 'support@homease.app';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        title: const Text('Help & Support', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            const Text('How can we help?', style: AppTextStyles.heading2),
            const SizedBox(height: 12),

            // Contact Support
            Card(
              child: ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Contact support'),
                subtitle: const Text('Email us for account or booking help'),
                trailing: TextButton(
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: supportEmail));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Support email copied to clipboard')),
                    );
                  },
                  child: const Text('Copy email'),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Report a problem
            Card(
              child: ListTile(
                leading: const Icon(Icons.report_problem_outlined),
                title: const Text('Report a problem'),
                subtitle: const Text('Tell us about a booking or app issue'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportProblemScreen()),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // FAQ
            const Text('FAQ', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            ExpansionTile(
              title: const Text('How do I cancel a booking?'),
              children: const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Open My Bookings, select a booking and tap Cancel. Contact support for refunds.'),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('How long until support replies?'),
              children: const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('We typically reply within 1 business day.'),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('How are providers verified?'),
              children: const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Providers are background checked and approved before joining.'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
