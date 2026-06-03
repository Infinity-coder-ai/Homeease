import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'user_provider.dart';

class ProviderAvailabilityState {
  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> slots;

  const ProviderAvailabilityState({
    this.isLoading = true,
    this.errorMessage,
    this.slots = const [],
  });

  ProviderAvailabilityState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<dynamic>? slots,
  }) {
    return ProviderAvailabilityState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      slots: slots ?? this.slots,
    );
  }
}

class ProviderAvailabilityNotifier extends StateNotifier<ProviderAvailabilityState> {
  final Ref ref;

  ProviderAvailabilityNotifier(this.ref) : super(const ProviderAvailabilityState()) {
    fetchAvailability();
  }

  Future<void> fetchAvailability() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final token = ref.read(userProvider).token ?? '';
    final result = await ApiProviderService.getProviderAvailability(token: token);

    if (result['success'] == true) {
      state = state.copyWith(
        isLoading: false,
        slots: result['data'] as List<dynamic>,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            result['message']?.toString() ?? 'Unable to load availability.',
      );
    }
  }

  void removeSlotLocally(int slotId) {
    state = state.copyWith(
      slots: state.slots.where((item) {
        final slot = item as Map<String, dynamic>;
        return slot['id'] != slotId;
      }).toList(),
    );
  }
}

final providerAvailabilityProvider = StateNotifierProvider.autoDispose<
    ProviderAvailabilityNotifier, ProviderAvailabilityState>(
  (ref) => ProviderAvailabilityNotifier(ref),
);
