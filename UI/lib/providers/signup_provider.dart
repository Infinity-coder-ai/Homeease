import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────────────────────────
// SIGNUP STATE
// This is a simple data class that holds the current state of
// the signup process. The UI reads this to know what to show.
// ─────────────────────────────────────────────────────────────────
class SignupState {
  final bool isLoading;      // true while waiting for FastAPI response
  final bool isSuccess;      // true when account was created successfully
  final String? errorMessage; // non-null when an error occurred

  const SignupState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });
}

// ─────────────────────────────────────────────────────────────────
// SIGNUP NOTIFIER
// Holds the business logic. When signup() is called:
//   1. Sets isLoading = true  → UI shows spinner
//   2. Calls the API
//   3. Sets isSuccess = true  OR  errorMessage = "..."
//   4. UI reacts via ref.listen()
// ─────────────────────────────────────────────────────────────────

//SignupNotifier is a controller that manages SignupState
class SignupNotifier extends StateNotifier<SignupState> {   //StateNotifier is a Riverpod class that stores state and allows updating it.
  // super(const SignupState()) → initial state: not loading, not success, no error
  SignupNotifier() : super(const SignupState());  // constructor of class and super calls the constructor of the parent class. , 
  //parent class is StateNotifier SignupState is passed as inital value

  Future<void> signup({   //Future means the function is asynchronous.
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    // Step 1: Tell the UI we are loading
    state = const SignupState(isLoading: true);   // it come from StateNotifier no need to define it

    // Step 2: Call the API (defined in api_service.dart)
    final result = await ApiAuthService.signup(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );

    // Step 3: Update state based on what the API returned
    if (result['success']) {
      state = const SignupState(isSuccess: true);
    } else {
      state = SignupState(errorMessage: result['message']);
    }
  }

  // Called after showing the error snackbar so the error doesn't persist
  void reset() => state = const SignupState();
}

// ─────────────────────────────────────────────────────────────────
// PROVIDER
// This is what the UI imports and uses.
// autoDispose → automatically destroys state when screen is closed
//               (no stale isSuccess = true when you reopen the screen)
// ─────────────────────────────────────────────────────────────────
final signupProvider =
    StateNotifierProvider.autoDispose<SignupNotifier, SignupState>(  //StateNotifierProvider This provider is specifically for StateNotifier classes.
  (ref) => SignupNotifier(),  // When provider is used → create SignupNotifier
);


// SignupState      → describes the current UI state
// SignupNotifier   → controls and changes the state
// signupProvider   → connects the UI to the notifier


// StateNotifier contain two things 
//  ├ state  ← current value
//  └ methods to change state

// This provider contains  two things:

// SignupNotifier  → controller
// SignupState     → data which is controlled 