import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
/// Top section of the login screen: headline + subtitle
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            'assets/sofa illustration.jpeg',
            height: 170,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Smart Home,\nSmooth Services',
          style: AppTextStyles.heading1,
        ),
        const SizedBox(height: 6),
        const Text(
          'Professional services at your fingertips.\nBook trusted experts in minutes.',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
