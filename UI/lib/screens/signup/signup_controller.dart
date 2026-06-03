import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// SignupController — ONLY holds UI state:
//   • TextEditingControllers (what the user typed in each field)
//   • FormKey (used to validate all fields at once)
//   • Password visibility toggles
//
// API logic has moved to SignupNotifier in:
//   lib/providers/signup_provider.dart
// ─────────────────────────────────────────────────────────────────
class SignupController {
  // Used by Form widget to validate all fields at once
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Each controller holds the text typed in one form field
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // true = password dots shown, false = password visible
  bool obscurePassword = true;
  bool obscureConfirm = true;

  // Must be called when the screen is disposed to free memory
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}
