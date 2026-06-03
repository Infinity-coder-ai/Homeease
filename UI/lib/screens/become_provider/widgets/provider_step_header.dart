import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ProviderStepHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const ProviderStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.heading2),
        const SizedBox(height: 6),
        Text(subtitle, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
