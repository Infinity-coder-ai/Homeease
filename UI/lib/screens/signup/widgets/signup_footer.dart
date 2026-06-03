import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Bottom section: Create Account button + OR divider + Log In link.
class SignupFooter extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onSignup;
  final VoidCallback onLoginTap;

  const SignupFooter({
    super.key,
    required this.isLoading,
    required this.onSignup,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : ElevatedButton(
                onPressed: onSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textDark,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text('Sign Up'),
              ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account? ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            GestureDetector(
              onTap: onLoginTap,
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
