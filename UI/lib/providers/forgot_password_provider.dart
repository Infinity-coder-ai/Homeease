import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class ForgotPasswordState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const ForgotPasswordState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });
}

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordNotifier() : super(const ForgotPasswordState());

  Future<void> sendResetLink({required String email}) async {
    state = const ForgotPasswordState(isLoading: true);

    final result = await ApiAuthService.forgotPassword(email: email);
    if (result['success'] == true) {
      state = const ForgotPasswordState(isSuccess: true);
    } else {
      state = ForgotPasswordState(
        errorMessage: result['message']?.toString() ?? 'Failed to send reset link.',
      );
    }
  }

  void reset() => state = const ForgotPasswordState();
}

final forgotPasswordProvider =
    StateNotifierProvider.autoDispose<ForgotPasswordNotifier, ForgotPasswordState>(
  (ref) => ForgotPasswordNotifier(),
);
