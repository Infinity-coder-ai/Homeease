import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'user_provider.dart';

class ProviderServicesState {
  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> services;

  const ProviderServicesState({
    this.isLoading = true,
    this.errorMessage,
    this.services = const [],
  });

  ProviderServicesState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<dynamic>? services,
  }) {
    return ProviderServicesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      services: services ?? this.services,
    );
  }
}

/// Loads services offered by the logged-in provider (profile + My Services screen).
class ProviderServicesNotifier extends StateNotifier<ProviderServicesState> {
  final Ref ref;

  ProviderServicesNotifier(this.ref) : super(const ProviderServicesState()) {
    fetchServices();
  }

  Future<void> fetchServices() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final token = ref.read(userProvider).token ?? '';
    if (token.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please login to continue.',
      );
      return;
    }

    final result = await ApiProviderService.getProviderServices(token: token);
    if (result['success'] == true) {
      state = state.copyWith(
        isLoading: false,
        services: result['data'] as List<dynamic>,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message']?.toString() ?? 'Unable to load services.',
      );
    }
  }
}

final providerServicesProvider =
    StateNotifierProvider.autoDispose<ProviderServicesNotifier, ProviderServicesState>(
  (ref) => ProviderServicesNotifier(ref),
);
