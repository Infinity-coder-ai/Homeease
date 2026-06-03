import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../login_controller.dart';

/// White card containing email and password fields.
class LoginForm extends StatelessWidget {
  final LoginController controller;
  final VoidCallback onStateChanged;

  const LoginForm({
    super.key,
    required this.controller,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Email ──────────────────────────────────────────────
          const Text('Email Address', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'you@example.com',
              prefixIcon:
                  Icon(Icons.mail_outline, color: AppColors.textLight),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@') || !v.contains('.')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Password ───────────────────────────────────────────
          const Text('Password', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: controller.passwordController,
            obscureText: controller.obscurePassword,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon:
                  const Icon(Icons.lock_outline, color: AppColors.textLight),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textLight,
                ),
                onPressed: () {
                  controller.obscurePassword = !controller.obscurePassword;
                  onStateChanged();
                },
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Password is required' : null,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
