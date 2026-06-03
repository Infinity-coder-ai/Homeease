import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class VerifyEmailState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final bool isResending;

  const VerifyEmailState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.isResending = false,
  });
}

class VerifyEmailNotifier extends StateNotifier<VerifyEmailState> {
  VerifyEmailNotifier() : super(const VerifyEmailState());

  Future<bool> resendOtp({required String email}) async {
    state = const VerifyEmailState(isResending: true);

    final result = await ApiService.resendSignupOtp(email: email);
    if (result['success'] != true) {
      state = VerifyEmailState(
        errorMessage: result['message']?.toString() ?? 'Failed to send OTP',
      );
      return false;
    }

    final data = result['data'] as Map<String, dynamic>? ?? {};
    if (data['sent'] != true) {
      state = VerifyEmailState(
        errorMessage: data['message']?.toString() ?? 'OTP not sent',
      );
      return false;
    }

    state = const VerifyEmailState();
    return true;
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    state = const VerifyEmailState(isLoading: true);

    final result = await ApiService.verifyEmailOtp(email: email, otp: otp);
    if (result['success'] == true) {
      state = const VerifyEmailState(isSuccess: true);
    } else {
      state = VerifyEmailState(
        errorMessage: result['message']?.toString() ?? 'Verification failed.',
      );
    }
  }

  void clearError() => state = const VerifyEmailState();
}

final verifyEmailProvider =
    StateNotifierProvider.autoDispose<VerifyEmailNotifier, VerifyEmailState>(
  (ref) => VerifyEmailNotifier(),
);
