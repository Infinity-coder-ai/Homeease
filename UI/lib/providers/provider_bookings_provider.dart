import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'user_provider.dart';

class ProviderBookingsState {
  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> bookings;

  const ProviderBookingsState({
    this.isLoading = true,
    this.errorMessage,
    this.bookings = const [],
  });

  ProviderBookingsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<dynamic>? bookings,
  }) {
    return ProviderBookingsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      bookings: bookings ?? this.bookings,
    );
  }
}

class ProviderBookingsNotifier extends StateNotifier<ProviderBookingsState> {
  final Ref ref;

  ProviderBookingsNotifier(this.ref) : super(const ProviderBookingsState()) {
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final token = ref.read(userProvider).token ?? '';
    if (token.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please login to continue.',
      );
      return;
    }

    final result = await ApiService.getProviderBookings(token: token);
    if (result['success'] == true) {
      state = state.copyWith(
        isLoading: false,
        bookings: result['data'] as List<dynamic>,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message']?.toString() ?? 'Unable to load bookings.',
      );
    }
  }
}

final providerBookingsProvider =
    StateNotifierProvider.autoDispose<ProviderBookingsNotifier, ProviderBookingsState>(
  (ref) => ProviderBookingsNotifier(ref),
);
