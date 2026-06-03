import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'user_provider.dart';

class ReportProblemState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const ReportProblemState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });
}

class ReportProblemNotifier extends StateNotifier<ReportProblemState> {
  final Ref ref;

  ReportProblemNotifier(this.ref) : super(const ReportProblemState());

  Future<void> submit({required String description}) async {
    state = const ReportProblemState(isLoading: true);

    final token = ref.read(userProvider).token ?? '';
    if (token.isEmpty) {
      state = const ReportProblemState(
        errorMessage: 'Please log in to submit a report.',
      );
      return;
    }

    final result = await ApiService.submitSupportReport(
      token: token,
      description: description,
    );

    if (result['success'] == true) {
      state = const ReportProblemState(isSuccess: true);
    } else {
      state = ReportProblemState(
        errorMessage: result['message']?.toString() ?? 'Unable to submit report.',
      );
    }
  }

  void reset() => state = const ReportProblemState();
}

final reportProblemProvider =
    StateNotifierProvider.autoDispose<ReportProblemNotifier, ReportProblemState>(
  (ref) => ReportProblemNotifier(ref),
);
