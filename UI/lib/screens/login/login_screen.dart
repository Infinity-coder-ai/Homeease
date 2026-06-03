import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod
import '../../theme/app_theme.dart';
import '../../providers/login_provider.dart'; // LoginState + loginProvider
import '../../providers/notification_provider.dart';
import '../../providers/user_provider.dart';
import 'login_controller.dart';
import 'widgets/login_header.dart';
import 'widgets/login_form.dart';
import 'widgets/login_footer.dart';
import '../auth/widgets/auth_backdrop.dart';
import '../signup/signup_screen.dart';
import '../home/home_screen.dart';
import 'forgot_password_screen.dart';
import '../verify/verify_email_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Holds only UI state: email/password text fields + visibility toggle
  final _formCtrl = LoginController();

  @override
  void dispose() {
    _formCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Watch login provider — rebuilds when isLoading changes
    final loginState = ref.watch(loginProvider);

    // Side effects: snackbar on success/error, navigation on success
    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged in successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
        final token = next.token ?? '';
        if (token.isNotEmpty) {
            final refreshToken = next.refreshToken ?? '';
            final name = _formCtrl.emailController.text.trim().split('@').first;
            ref.read(userProvider.notifier).setUser(
              name: name,
              token: token,
            );
            ref.read(userProvider.notifier).persistUser(
              name: name,
              accessToken: token,
              refreshToken: refreshToken,
            );
            ref.read(userProvider.notifier).fetchMe();
            // Refresh backend notifications immediately after login so the inbox is populated.
            ref.read(notificationProvider.notifier).fetchNotifications();
            ref.read(notificationProvider.notifier).fetchUnreadCount();
        }
        // Navigate to HomeScreen, replacing login so user can't go back
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        // If email is not verified, route user to the OTP verification screen.
        if (next.errorMessage!.toLowerCase().contains('email not verified')) {
          final email = _formCtrl.emailController.text.trim();
          if (email.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email)),
            );
          }
        }
        // Reset so the error snackbar doesn't show again on rebuild
        ref.read(loginProvider.notifier).reset();
      }
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: AuthBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.screenPadding,
                  child: Form(
                    key: _formCtrl.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        const LoginHeader(),
                        const SizedBox(height: AppSpacing.xl),

                        LoginForm(
                          controller: _formCtrl,
                          onStateChanged: () => setState(() {}),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        LoginFooter(
                          // isLoading comes from Riverpod provider
                          isLoading: loginState.isLoading,
                          onLogin: () {
                            if (!_formCtrl.formKey.currentState!.validate()) return;
                            // Call the notifier — it calls ApiService and updates state
                            ref.read(loginProvider.notifier).login(
                              email: _formCtrl.emailController.text.trim(),
                              password: _formCtrl.passwordController.text,
                            );
                          },
                          onForgotPassword: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          onSignupTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SignupScreen()),
                            );
                          },
                        ),

                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
