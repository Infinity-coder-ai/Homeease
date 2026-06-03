import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'user_provider.dart';

class ProviderDocumentsState {
  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> documents;

  const ProviderDocumentsState({
    this.isLoading = true,
    this.errorMessage,
    this.documents = const [],
  });

  ProviderDocumentsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<dynamic>? documents,
  }) {
    return ProviderDocumentsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      documents: documents ?? this.documents,
    );
  }
}

class ProviderDocumentsNotifier extends StateNotifier<ProviderDocumentsState> {
  final Ref ref;

  ProviderDocumentsNotifier(this.ref) : super(const ProviderDocumentsState()) {
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final token = ref.read(userProvider).token ?? '';
    final result = await ApiProviderService.getProviderDocuments(token: token);

    if (result['success'] == true) {
      state = state.copyWith(
        isLoading: false,
        documents: result['data'] as List<dynamic>,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message']?.toString() ?? 'Unable to load documents.',
      );
    }
  }
}

final providerDocumentsProvider =
    StateNotifierProvider.autoDispose<ProviderDocumentsNotifier, ProviderDocumentsState>(
  (ref) => ProviderDocumentsNotifier(ref),
);
