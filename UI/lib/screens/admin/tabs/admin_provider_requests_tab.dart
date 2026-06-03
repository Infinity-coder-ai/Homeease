// Provider approval tab: header, filters, and sub-tab content.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/user_provider.dart';
import '../../../theme/app_theme.dart';
import 'admin_provider_tab_lists.dart';

class AdminProviderRequestsTab extends ConsumerWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> requests;
  final List<dynamic> approved;
  final List<dynamic> rejected;
  final int providerTabIndex;
  final TextEditingController cityFilterCtrl;
  final TextEditingController ratingFilterCtrl;
  final Future<void> Function() onRefresh;
  final void Function(int index) onProviderTabChanged;
  final VoidCallback onCityOrRatingChanged;
  final VoidCallback onOpenProfile;
  final void Function(int providerId, int index) onReject;
  final void Function(int providerId, int index) onApproveBackground;
  final void Function(int providerId, int index) onAssignRole;
  final void Function(int providerId, int index) onDeactivate;
  final void Function(int providerId) onViewDetails;

  const AdminProviderRequestsTab({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.requests,
    required this.approved,
    required this.rejected,
    required this.providerTabIndex,
    required this.cityFilterCtrl,
    required this.ratingFilterCtrl,
    required this.onRefresh,
    required this.onProviderTabChanged,
    required this.onCityOrRatingChanged,
    required this.onOpenProfile,
    required this.onReject,
    required this.onApproveBackground,
    required this.onAssignRole,
    required this.onDeactivate,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(userProvider);
    final token = admin.token ?? '';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                GestureDetector(
                  onTap: onOpenProfile,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        admin.name.isNotEmpty
                            ? admin.name[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Admin Dashboard',
                          style: AppTextStyles.heading2),
                      const SizedBox(height: 4),
                      Text(
                        admin.name.isNotEmpty
                            ? admin.name
                            : 'Administrator',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const GlassCard(
              tintColor: AppColors.accentAmber,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Provider Approval — 3 Steps',
                      style: AppTextStyles.heading3),
                  SizedBox(height: 6),
                  Text(
                    '① Verify Documents  ②  Approve Background Check  ③  Assign Provider Role',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassCard(
              tintColor: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filters', style: AppTextStyles.heading3),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: cityFilterCtrl,
                    onChanged: (_) => onCityOrRatingChanged(),
                    decoration: const InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: ratingFilterCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => onCityOrRatingChanged(),
                    decoration: const InputDecoration(
                      labelText: 'Min rating (1–5)',
                      prefixIcon: Icon(Icons.star_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DefaultTabController(
              length: 3,
              initialIndex: providerTabIndex,
              child: Column(
                children: [
                  TabBar(
                    onTap: onProviderTabChanged,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textLight,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: 'Pending'),
                      Tab(text: 'Approved'),
                      Tab(text: 'Rejected'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (errorMessage != null)
              GlassCard(
                tintColor: AppColors.accentCoral,
                child: Text(errorMessage!, style: AppTextStyles.bodyMedium),
              )
            else if (providerTabIndex == 0)
              AdminPendingRequestsList(
                requests: requests,
                token: token,
                onReject: onReject,
                onApproveBackground: onApproveBackground,
              )
            else if (providerTabIndex == 1)
              AdminApprovedProvidersList(
                approved: approved,
                onAssignRole: onAssignRole,
                onDeactivate: onDeactivate,
                onViewDetails: onViewDetails,
              )
            else
              AdminRejectedProvidersList(
                rejected: rejected,
                onViewDetails: onViewDetails,
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
