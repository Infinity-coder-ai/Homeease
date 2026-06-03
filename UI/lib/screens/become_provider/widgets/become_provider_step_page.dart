// Wizard page shell: promo header, step title, and step body slot.
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class BecomeProviderStepPage extends StatelessWidget {
  final int stepIndex;
  final Widget stepBody;

  const BecomeProviderStepPage({
    super.key,
    required this.stepIndex,
    required this.stepBody,
  });

  static const _titles = <String>[
    'Personal Information',
    'Select Your Service',
    'Availability',
    'Upload Documents',
  ];

  static const _subtitles = <String>[
    'Please provide your personal details.',
    'Choose the service you provide.',
    'Add the time slots when you can take bookings.',
    'Please upload clear photos of the documents.',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grow Your Business',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Earn more. Work smarter. Get discovered by customers nearby.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Step ${stepIndex + 1} of 4',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(_titles[stepIndex], style: AppTextStyles.heading1),
          const SizedBox(height: 6),
          Text(_subtitles[stepIndex], style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          stepBody,
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
