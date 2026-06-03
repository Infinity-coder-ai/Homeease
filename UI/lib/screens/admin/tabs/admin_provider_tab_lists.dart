// Pending / Approved / Rejected list sections for the admin provider tab.
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../widgets/admin_shared_widgets.dart';
import '../widgets/approved_provider_card.dart';
import '../widgets/pending_provider_card.dart';

class AdminPendingRequestsList extends StatelessWidget {
  final List<dynamic> requests;
  final String token;
  final void Function(int providerId, int index) onReject;
  final void Function(int providerId, int index) onApproveBackground;

  const AdminPendingRequestsList({
    super.key,
    required this.requests,
    required this.token,
    required this.onReject,
    required this.onApproveBackground,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const GlassCard(
        tintColor: AppColors.accentBlue,
        child: Text('No pending provider requests.',
            style: AppTextStyles.bodyMedium),
      );
    }
    return Column(
      children: requests.asMap().entries.map((entry) {
        final index = entry.key;
        final req = entry.value as Map<String, dynamic>;
        final providerId = req['id'] as int?;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: PendingProviderCard(
            request: req,
            token: token,
            onApproveBackground: providerId == null
                ? null
                : () => onApproveBackground(providerId, index),
            onReject: providerId == null
                ? null
                : () => onReject(providerId, index),
          ),
        );
      }).toList(),
    );
  }
}

class AdminApprovedProvidersList extends StatelessWidget {
  final List<dynamic> approved;
  final void Function(int providerId, int index) onAssignRole;
  final void Function(int providerId, int index) onDeactivate;
  final void Function(int providerId) onViewDetails;

  const AdminApprovedProvidersList({
    super.key,
    required this.approved,
    required this.onAssignRole,
    required this.onDeactivate,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (approved.isEmpty) {
      return const GlassCard(
        tintColor: AppColors.accentGreen,
        child: Text('No approved providers yet.',
            style: AppTextStyles.bodyMedium),
      );
    }
    return Column(
      children: approved.asMap().entries.map((entry) {
        final index = entry.key;
        final prov = entry.value as Map<String, dynamic>;
        final providerId = prov['id'] as int?;
        final roleAssigned = prov['role']?.toString() == 'provider';
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ApprovedProviderCard(
            provider: prov,
            roleAssigned: roleAssigned,
            onAssignRole: providerId == null || roleAssigned
                ? null
                : () => onAssignRole(providerId, index),
            onDeactivate: providerId == null
                ? null
                : () => onDeactivate(providerId, index),
            onViewDetails: providerId == null
                ? null
                : () => onViewDetails(providerId),
          ),
        );
      }).toList(),
    );
  }
}

class AdminRejectedProvidersList extends StatelessWidget {
  final List<dynamic> rejected;
  final void Function(int providerId) onViewDetails;

  const AdminRejectedProvidersList({
    super.key,
    required this.rejected,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (rejected.isEmpty) {
      return const GlassCard(
        tintColor: AppColors.accentCoral,
        child: Text('No rejected providers.',
            style: AppTextStyles.bodyMedium),
      );
    }
    return Column(
      children: rejected.map((entry) {
        final prov = entry as Map<String, dynamic>;
        final providerId = prov['id'] as int?;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: GlassCard(
            tintColor: AppColors.accentCoral,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        prov['name']?.toString() ?? 'Provider',
                        style: AppTextStyles.heading3,
                      ),
                    ),
                    const AdminStatusChip(
                      label: 'Rejected',
                      color: AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Email: ${prov['email'] ?? '-'}',
                    style: AppTextStyles.bodyMedium),
                Text('Phone: ${prov['phone'] ?? '-'}',
                    style: AppTextStyles.bodyMedium),
                Text(
                  'Location: ${prov['city'] ?? '-'}, ${prov['area'] ?? '-'}',
                  style: AppTextStyles.bodyMedium,
                ),
                if (providerId != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => onViewDetails(providerId),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
