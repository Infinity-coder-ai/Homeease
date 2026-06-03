import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod
import '../../theme/app_theme.dart';
import '../../providers/signup_provider.dart'; // SignupState + signupProvider
import 'signup_controller.dart';
import 'widgets/signup_header.dart';
import 'widgets/signup_form.dart';
import 'widgets/signup_footer.dart';
import '../login/login_screen.dart';
import '../verify/verify_email_screen.dart';

// ConsumerStatefulWidget = StatefulWidget that can also read Riverpod providers.
// Use when you need both local state (TextEditingControllers)
// AND provider state (isLoading, isSuccess) at the same time.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

// ConsumerState gives access to `ref` — the Riverpod handle
class _SignupScreenState extends ConsumerState<SignupScreen> {
  // Holds only UI state: text fields + visibility toggles
  final _formCtrl = SignupController();

  @override
  void dispose() {
    _formCtrl.dispose();
    super.dispose(); //Flutter's internal framework also needs to clean up
  }

//   SystemChrome is a class from:
// import 'package:flutter/services.dart';
// It allows Flutter apps to control system-level UI elements, such as: Status bar color Status bar icons Navigation bar color Screen orientation
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(               
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // ref.watch → rebuilds this widget whenever SignupState changes
    // (e.g. isLoading flips true/false)

    //final state = ref.watch(signupProvider);
    final signupState = ref.watch(signupProvider);  //it store signup state , because Riverpod returns the state, not the notifier.

    // ref.listen → runs a side effect when state changes, WITHOUT rebuilding ,ref = tool used by widgets to access providers
    // Perfect for SnackBars and navigation
    ref.listen<SignupState>(signupProvider, (previous, next) {    //Side effects are things that should happen once, not rebuild UI. Examples: show snackbar navigate to another screen show dialog log analytics
      if (next.isSuccess) {
        final email = _formCtrl.emailController.text.trim();
        // Signup intent already sent OTP from backend (/auth/signup/start).
        // Navigate to OTP verification screen.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email)),
        );
      }
      if (next.errorMessage != null) {
        // Show the error from FastAPI (e.g. "Email already registered")
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        // Clear error so it doesn't show again on next rebuild
        ref.read(signupProvider.notifier).reset();// reset the
      }
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F2),
        body: SafeArea(
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
                      const SignupHeader(),
                      const SizedBox(height: AppSpacing.lg),
                      SignupForm(
                        controller: _formCtrl,
                        onStateChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SignupFooter(
                isLoading: signupState.isLoading,
                onSignup: () {
                  if (!_formCtrl.formKey.currentState!.validate()) return;
                  ref.read(signupProvider.notifier).signup(
                    name: _formCtrl.nameController.text.trim(),
                    email: _formCtrl.emailController.text.trim(),
                    password: _formCtrl.passwordController.text,
                    phone: _formCtrl.phoneController.text.trim(),
                  );
                },
                onLoginTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
