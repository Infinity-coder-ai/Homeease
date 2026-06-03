import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Bottom section: Login button + OR divider + Sign Up link.
class LoginFooter extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onSignupTap;
  final VoidCallback onForgotPassword;

  const LoginFooter({
    super.key,
    required this.isLoading,
    required this.onLogin,
    required this.onSignupTap,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // ── Button / Loader ──────────────────────────────────────
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : ElevatedButton(
                  onPressed: onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textDark,
                    minimumSize: const Size(double.infinity, 54),
                  ),
                  child: const Text('Log In'),
                ),

          const SizedBox(height: AppSpacing.md),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              child: const Text('Forgot password?'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── OR divider ───────────────────────────────────────────
          const Row(
            children: [
              Expanded(child: Divider(color: AppColors.inputBorder)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  'or',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.inputBorder)),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Social sign-in icons removed — backend does not support social logins.

          // ── Sign Up link ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: onSignupTap,
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Social icons removed; helper deleted.
