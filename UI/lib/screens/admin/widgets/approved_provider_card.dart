// Card for an approved provider: assign role (step 3), deactivate, view details.
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'admin_shared_widgets.dart';

class ApprovedProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;
  final bool roleAssigned;
  final VoidCallback? onAssignRole;
  final VoidCallback? onDeactivate;
  final VoidCallback? onViewDetails;

  const ApprovedProviderCard({
    super.key,
    required this.provider,
    required this.roleAssigned,
    required this.onAssignRole,
    required this.onDeactivate,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final name = provider['name']?.toString() ?? 'Provider';
    final email = provider['email']?.toString() ?? '-';
    final phone = provider['phone']?.toString() ?? '-';
    final city = provider['city']?.toString() ?? '-';
    final area = provider['area']?.toString() ?? '-';
    final pincode = provider['pincode']?.toString() ?? '-';

    return GlassCard(
      tintColor: AppColors.accentGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: AppTextStyles.heading3)),
              AdminStatusChip(
                label: roleAssigned ? 'Provider' : 'BG Verified',
                color: roleAssigned ? AppColors.success : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Email: $email', style: AppTextStyles.bodyMedium),
          Text('Phone: $phone', style: AppTextStyles.bodyMedium),
          Text('Location: $city, $area ($pincode)',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          AdminStepFlowIndicator(
            step1Done: true,
            step2Done: true,
            step3Done: roleAssigned,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  child: const Text('Details'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDeactivate,
                  child: const Text('Deactivate'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 12),
          AdminSectionHeader(
            icon: Icons.manage_accounts_rounded,
            label: 'Step 3 — Assign Provider Role',
            trailingWidget: roleAssigned
                ? const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 18)
                : null,
          ),
          const SizedBox(height: 10),
          if (!roleAssigned) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Background check passed. Assign the provider role to unlock the dashboard for this user.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
                onPressed: onAssignRole,
                icon: const Icon(Icons.how_to_reg_rounded, size: 18),
                label: const Text('Assign Provider Role'),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.30),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_rounded,
                      color: AppColors.success, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Provider Role Assigned — Dashboard Unlocked',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
