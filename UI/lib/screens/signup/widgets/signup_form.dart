import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';
import '../signup_controller.dart';

/// White card containing all five form fields.
/// Receives the controller so it can read/write field values and toggle state.
class SignupForm extends StatelessWidget {
  final SignupController controller;
  final VoidCallback onStateChanged;

  const SignupForm({
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
          const Text('Full Name', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: controller.nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Anna Grace',
              prefixIcon:
                  Icon(Icons.person_outline, color: AppColors.textLight),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),

          const SizedBox(height: AppSpacing.md),

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

          const Text('Phone Number', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]'))
            ],
            decoration: const InputDecoration(
              hintText: '+92 300 1234567',
              prefixIcon:
                  Icon(Icons.phone_outlined, color: AppColors.textLight),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
          ),

          const SizedBox(height: AppSpacing.md),

          const Text('Password', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: controller.passwordController,
            obscureText: controller.obscurePassword,
            decoration: InputDecoration(
              hintText: 'Min. 8 characters',
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
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 8) return 'Minimum 8 characters';
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.md),

          const Text('Confirm Password', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: controller.confirmPasswordController,
            obscureText: controller.obscureConfirm,
            decoration: InputDecoration(
              hintText: 'Re-enter password',
              prefixIcon:
                  const Icon(Icons.lock_outline, color: AppColors.textLight),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textLight,
                ),
                onPressed: () {
                  controller.obscureConfirm = !controller.obscureConfirm;
                  onStateChanged();
                },
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != controller.passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
