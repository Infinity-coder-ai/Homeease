import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Placeholder when a wizard step has no content or is already complete.
class EmptyStepCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmptyStepCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8EAF1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
