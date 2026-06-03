import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
/// Top section of the signup screen: headline + subtitle
class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/3d clipboard.jpeg',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height : 20),
        const Text('Create Account', style: TextStyle(fontSize: 30),),
        const SizedBox(height: 4),
        const Text(
          'Sign up to get started with HomeEase',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
