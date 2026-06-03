import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/verify_email_provider.dart';
import '../../theme/app_theme.dart';
import '../login/login_screen.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _otpCtrl = TextEditingController();
  int _seconds = 45;
  Timer? _timer;

  Future<void> _goBack() async {
    final popped = await Navigator.maybePop(context);
    if (popped || !mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 1) {
        t.cancel();
        setState(() => _seconds = 0);
        return;
      }
      setState(() => _seconds -= 1);
    });
  }

  Future<void> _verify() async {
    final otp = _otpCtrl.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit OTP.')),
      );
      return;
    }

    await ref.read(verifyEmailProvider.notifier).verifyOtp(
          email: widget.email,
          otp: otp,
        );
    if (!mounted) return;

    final state = ref.read(verifyEmailProvider);
    if (state.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verified. Please log in.')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => route.isFirst,
      );
    } else if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
      ref.read(verifyEmailProvider.notifier).clearError();
    }
  }

  Future<void> _resend() async {
    if (_seconds > 0) return;
    _startTimer();

    final sent = await ref.read(verifyEmailProvider.notifier).resendOtp(
          email: widget.email.trim(),
        );
    if (!mounted) return;

    if (sent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent. Check your email.')),
      );
    } else {
      final message = ref.read(verifyEmailProvider).errorMessage;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        ref.read(verifyEmailProvider.notifier).clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final verifyState = ref.watch(verifyEmailProvider);
    final email = widget.email;
    final resendText = _seconds > 0
        ? 'Resend OTP in 00:${_seconds.toString().padLeft(2, '0')}'
        : 'Resend OTP';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark),
          onPressed: _goBack,
        ),
        title: const Text('Verify Email', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Enter the 6-digit OTP sent to\n$email',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  hintText: 'Enter OTP',
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: verifyState.isResending ? null : _resend,
                child: Text(resendText),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: verifyState.isLoading ? null : _verify,
                child: verifyState.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
