import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────
// LOGIN STATE
// Same pattern as SignupState.
// On success, also stores the access_token returned by FastAPI.
// ─────────────────────────────────────────────────────────────────
class LoginState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final String? token; // JWT access token received on successful login
  final String? refreshToken; // Opaque refresh token stored securely by the app

  const LoginState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.token,
    this.refreshToken,
  });
}

// ─────────────────────────────────────────────────────────────────
// LOGIN NOTIFIER
// Same pattern as SignupNotifier.
// On success, stores the token in state so the screen can save it.
// ─────────────────────────────────────────────────────────────────
class LoginNotifier extends StateNotifier<LoginState> {
 LoginNotifier()                    // ← constructor of LoginNotifier (takes no arguments)
    :                              // ← initializer list separator
    super(const LoginState());      // ← calls parent (StateNotifier) constructor with initial state

  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Step 1: Show spinner
    state = const LoginState(isLoading: true);

    // Step 2: Hit FastAPI POST /login
    final result = await ApiService.login(
      email: email,
      password: password,
    );

    // Step 3: Update state
    if (result['success']) {
      // Store the token — screen will save it to SharedPreferences
      state = LoginState(
        isSuccess: true,
        token: result['access_token'],
        refreshToken: result['refresh_token'],
      );
    } else {
      state = LoginState(errorMessage: result['message']);
    }
  }

  void reset() => state = const LoginState();
}

// ─────────────────────────────────────────────────────────────────
// PROVIDER
// autoDispose → clears state (including stored token) when screen closes
// ─────────────────────────────────────────────────────────────────
final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(),
);
