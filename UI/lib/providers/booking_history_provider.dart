import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'user_provider.dart';

class BookingHistoryState {
  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> bookings;

  const BookingHistoryState({
    this.isLoading = true,
    this.errorMessage,
    this.bookings = const [],
  });

  BookingHistoryState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<dynamic>? bookings,
  }) {
    return BookingHistoryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      bookings: bookings ?? this.bookings,
    );
  }
}

class BookingHistoryNotifier extends StateNotifier<BookingHistoryState> {
  final Ref ref;

  BookingHistoryNotifier(this.ref) : super(const BookingHistoryState()) {
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final token = ref.read(userProvider).token ?? '';
    if (token.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please login to view your bookings.',
      );
      return;
    }

    final result = await ApiBookingService.getMyBookings(token: token);
    if (result['success'] == true) {
      state = state.copyWith(
        isLoading: false,
        bookings: result['data'] as List<dynamic>,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message'] as String?,
      );
    }
  }
}

final bookingHistoryProvider =
    StateNotifierProvider.autoDispose<BookingHistoryNotifier, BookingHistoryState>(
  (ref) => BookingHistoryNotifier(ref),
);
