import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'user_provider.dart';

// ─────────────────────────────────────────────────────────────────
// PROVIDER SEARCH STATE
// Holds everything the ProviderSearchScreen needs:
//   - The fetched providers list
//   - Filtered list (after trust score filter)
//   - Loading / error flags
//   - Current filter values
// ─────────────────────────────────────────────────────────────────
class ProviderSearchState {
  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> providers;    // raw list from API
  final List<dynamic> filtered;     // after trust score filter
  final double minTrustScore;

  const ProviderSearchState({
    this.isLoading = true,
    this.errorMessage,
    this.providers = const [],
    this.filtered = const [],
    this.minTrustScore = 0,
  });

  ProviderSearchState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<dynamic>? providers,
    List<dynamic>? filtered,
    double? minTrustScore,
  }) {
    return ProviderSearchState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      providers: providers ?? this.providers,
      filtered: filtered ?? this.filtered,
      minTrustScore: minTrustScore ?? this.minTrustScore,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PROVIDER SEARCH NOTIFIER
// Handles API calls and filter logic, keeps the screen clean.
// ─────────────────────────────────────────────────────────────────
class ProviderSearchNotifier extends StateNotifier<ProviderSearchState> {
  final int serviceId;
  final Ref ref;

  ProviderSearchNotifier(this.ref, this.serviceId)
      : super(const ProviderSearchState()) {
    fetchProviders();
  }

  Future<void> fetchProviders({String? city, String? area}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final token = ref.read(userProvider).token ?? '';
      final result = await ApiCatalogService.searchProviders(
        serviceId: serviceId,
        token: token,
        city: city,
        area: area,
      );

      if (result['success']) {
        final providers = result['data'] as List<dynamic>;
        state = state.copyWith(
          isLoading: false,
          providers: providers,
          filtered: _applyFilter(providers, state.minTrustScore),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result['message'] as String?,
        );
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to reach the server. Check your connection and IP.',
      );
    }
  }

  void setTrustScore(double score) {
    state = state.copyWith(
      minTrustScore: score,
      filtered: _applyFilter(state.providers, score),
    );
  }

  List<dynamic> _applyFilter(List<dynamic> providers, double minScore) {
    return providers.where((p) {
      final trustScore = (p['trust_score'] as num?)?.toDouble() ?? 0.0;
      return trustScore >= minScore;
    }).toList();
  }
}

// ─────────────────────────────────────────────────────────────────
// PROVIDER (family)
// Uses .family so each serviceId gets its own independent state.
// autoDispose → clears when leaving the search screen.
// ─────────────────────────────────────────────────────────────────
final providerSearchProvider = StateNotifierProvider.autoDispose
    .family<ProviderSearchNotifier, ProviderSearchState, int>(
  (ref, serviceId) => ProviderSearchNotifier(ref, serviceId),
);
