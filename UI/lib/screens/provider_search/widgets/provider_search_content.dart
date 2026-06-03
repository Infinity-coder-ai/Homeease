import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'provider_card.dart';

class ProviderSearchContent extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> providers;
  final VoidCallback onRetry;
  final void Function(Map<String, dynamic> provider) onSelectProvider;

  const ProviderSearchContent({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.providers,
    required this.onRetry,
    required this.onSelectProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 56,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              errorMessage!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (providers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, color: AppColors.textLight, size: 64),
            SizedBox(height: AppSpacing.md),
            Text('No providers found', style: AppTextStyles.bodyMedium),
            SizedBox(height: AppSpacing.xs),
            Text('Try adjusting your filters', style: AppTextStyles.hint),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < providers.length; i++) ...[
          ProviderCard(
            provider: providers[i],
            onTap: () => onSelectProvider(providers[i]),
          ),
          if (i != providers.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
