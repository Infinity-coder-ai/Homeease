import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/provider_search_provider.dart';
import '../../providers/rating_refresh_provider.dart';
import '../../theme/app_theme.dart';
import '../booking/booking_screen.dart';
import 'widgets/provider_search_content.dart';

String bannerAssetForService(int serviceId) {
  switch (serviceId) {
    case 6:
    case 7:
    case 8:
    case 12:
    case 13:
    case 14:
      return 'assets/banner1.jpg';
    default:
      return 'assets/banner2.jpg';
  }
}

class ProviderSearchScreen extends ConsumerStatefulWidget {
  final int serviceId;
  final String serviceName;
  final String imageAsset;

  const ProviderSearchScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.imageAsset,
  });

  @override
  ConsumerState<ProviderSearchScreen> createState() => _ProviderSearchScreenState();
}

class _ProviderSearchScreenState extends ConsumerState<ProviderSearchScreen> {
  final _cityCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  ProviderSubscription<int>? _ratingSub;

  @override
  void initState() {
    super.initState();
    _ratingSub = ref.listenManual<int>(ratingRefreshProvider, (_, __) {
      _onSearch();
    });
  }

  @override
  void dispose() {
    _ratingSub?.close();
    _cityCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final city = _cityCtrl.text.trim();
    final area = _areaCtrl.text.trim();
    ref.read(providerSearchProvider(widget.serviceId).notifier).fetchProviders(
      city: city.isEmpty ? null : city,
      area: area.isEmpty ? null : area,
    );
  }

  void _showFilterSheet() {
    final searchState = ref.read(providerSearchProvider(widget.serviceId));
    double tempScore = searchState.minTrustScore;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius:  BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Providers', style: AppTextStyles.heading2),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _cityCtrl,
                style: const TextStyle(color: AppColors.textDark),
                decoration: const InputDecoration(hintText: 'City'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _areaCtrl,
                style: const TextStyle(color: AppColors.textDark),
                decoration: const InputDecoration(hintText: 'Area'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  const Text('Min Trust Score', style: AppTextStyles.bodyMedium),
                  const Spacer(),
                  Text(
                    tempScore.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Slider(
                value: tempScore, min: 0, max: 5, divisions: 10,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.inputBorder,
                onChanged: (v) => setSheetState(() => tempScore = v),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(providerSearchProvider(widget.serviceId).notifier)
                        .setTrustScore(tempScore);
                    Navigator.pop(ctx);
                    _onSearch();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the Riverpod provider — rebuilds when state changes
    final searchState = ref.watch(providerSearchProvider(widget.serviceId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.serviceName, style: AppTextStyles.heading3),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.textMedium),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AspectRatio(
                aspectRatio: 16 / 7,
                child: Image.asset(
                  widget.imageAsset,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ProviderSearchContent(
              isLoading: searchState.isLoading,
              errorMessage: searchState.errorMessage,
              providers: searchState.filtered,
              onRetry: _onSearch,
              onSelectProvider: (provider) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScreen(
                      provider: provider,
                      serviceId: widget.serviceId,
                      serviceName: widget.serviceName,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
