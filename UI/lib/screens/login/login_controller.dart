import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// LoginController — ONLY holds UI state:
//   • TextEditingControllers (email + password fields)
//   • FormKey for validation
//   • Password visibility toggle
//
// API logic has moved to LoginNotifier in:
//   lib/providers/login_provider.dart
// ─────────────────────────────────────────────────────────────────
class LoginController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // true = password hidden (dots), false = password visible
  bool obscurePassword = true;

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
