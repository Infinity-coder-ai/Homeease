import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/provider_services_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../theme/app_theme.dart';
import '../../provider_dashboard/provider_application_status_screen.dart';
import '../widgets/become_provider.dart';

/// Profile-tab block for non-providers (apply) and providers (mode toggle + services).
class ProfileProviderSection extends ConsumerWidget {
  /// Called after provider mode changes so the parent can reset the nav tab.
  final VoidCallback? onProviderModeChanged;

  const ProfileProviderSection({super.key, this.onProviderModeChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (!user.isProvider) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Become a Provider', style: AppTextStyles.heading3),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProviderApplicationStatusScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.timeline_rounded),
              label: const Text('Track Application Status'),
            ),
          ),
          const SizedBox(height: 10),
          const BecomeProvider(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Provider Tools', style: AppTextStyles.heading3),
        const SizedBox(height: 10),
        GlassCard(
          tintColor: AppColors.secondary,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Provider Mode', style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text(
                      user.providerMode
                          ? 'You are viewing the provider dashboard.'
                          : 'Switch to manage your provider profile.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              Switch(
                value: user.providerMode,
                activeThumbColor: AppColors.primary,
                onChanged: (value) async {
                  ref.read(userProvider.notifier).setProviderMode(value);
                  await ref.read(userProvider.notifier).persistProviderMode(value);
                  onProviderModeChanged?.call();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('Your Services', style: AppTextStyles.heading3),
        const SizedBox(height: 10),
        const _ProviderServicesList(),
      ],
    );
  }
}

/// Lists services from [providerServicesProvider] (shared with My Services screen).
class _ProviderServicesList extends ConsumerWidget {
  const _ProviderServicesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesState = ref.watch(providerServicesProvider);

    if (servicesState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (servicesState.errorMessage != null) {
      return Text(
        servicesState.errorMessage!,
        style: AppTextStyles.bodyMedium,
      );
    }

    if (servicesState.services.isEmpty) {
      return const Text(
        'No services added yet.',
        style: AppTextStyles.bodyMedium,
      );
    }

    return Column(
      children: servicesState.services.map((service) {
        final map = service as Map<String, dynamic>;
        final name = map['service_name']?.toString() ?? 'Service';
        final price = map['price'];
        final priceText = price is num ? 'Rs ${price.toStringAsFixed(0)}' : 'Rs -';

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: GlassCard(
            tintColor: AppColors.accentLavender,
            child: Row(
              children: [
                Expanded(child: Text(name, style: AppTextStyles.heading3)),
                Text(priceText, style: AppTextStyles.heading3),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
