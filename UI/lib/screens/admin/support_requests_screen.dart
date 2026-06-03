import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/support_reports_provider.dart';
import '../../theme/app_theme.dart';

class AdminSupportRequestsScreen extends ConsumerWidget {
  const AdminSupportRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsState = ref.watch(supportReportsProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(supportReportsProvider.notifier).fetchReports(),
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            const SizedBox(height: AppSpacing.lg),
            const Text('Support Requests', style: AppTextStyles.heading2),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Reports submitted by users are listed here.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (reportsState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (reportsState.errorMessage != null)
              GlassCard(
                tintColor: AppColors.accentCoral,
                child: Text(reportsState.errorMessage!, style: AppTextStyles.bodyMedium),
              )
            else if (reportsState.reports.isEmpty)
              const GlassCard(
                tintColor: AppColors.accentBlue,
                child: Text('No support requests yet.', style: AppTextStyles.bodyMedium),
              )
            else
              ...reportsState.reports.map((entry) {
                final report = entry as Map<String, dynamic>;
                final name = report['user_name']?.toString() ?? 'User';
                final email = report['user_email']?.toString() ?? '-';
                final status = report['status']?.toString() ?? 'OPEN';
                final description = report['description']?.toString() ?? '';
                final createdAt = report['created_at']?.toString() ?? '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: GlassCard(
                    tintColor: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(name, style: AppTextStyles.heading3),
                            ),
                            _StatusChip(label: status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Email: $email', style: AppTextStyles.bodyMedium),
                        if (createdAt.isNotEmpty)
                          Text('Submitted: $createdAt', style: AppTextStyles.hint),
                        const SizedBox(height: 10),
                        Text(description, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final normalized = label.toUpperCase();
    final color = normalized == 'OPEN'
        ? AppColors.warning
        : normalized == 'RESOLVED'
            ? AppColors.success
            : AppColors.textLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
