import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'user_provider.dart';

class SupportReportsState {
  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> reports;

  const SupportReportsState({
    this.isLoading = true,
    this.errorMessage,
    this.reports = const [],
  });

  SupportReportsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<dynamic>? reports,
  }) {
    return SupportReportsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      reports: reports ?? this.reports,
    );
  }
}

/// Admin list of user-submitted support / problem reports.
class SupportReportsNotifier extends StateNotifier<SupportReportsState> {
  final Ref ref;

  SupportReportsNotifier(this.ref) : super(const SupportReportsState()) {
    fetchReports();
  }

  Future<void> fetchReports() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final token = ref.read(userProvider).token ?? '';
    if (token.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please login to continue.',
      );
      return;
    }

    final result = await ApiService.getSupportReports(token: token);
    if (result['success'] == true) {
      state = state.copyWith(
        isLoading: false,
        reports: result['data'] as List<dynamic>,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message']?.toString() ?? 'Unable to load reports.',
      );
    }
  }
}

final supportReportsProvider =
    StateNotifierProvider.autoDispose<SupportReportsNotifier, SupportReportsState>(
  (ref) => SupportReportsNotifier(ref),
);
