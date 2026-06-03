// Card for a pending provider: document review (step 1) + background check (step 2).
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'admin_shared_widgets.dart';
import 'pending_provider_docs_panel.dart';

class PendingProviderCard extends StatefulWidget {
  final Map<String, dynamic> request;
  final String token;
  final VoidCallback? onApproveBackground;
  final VoidCallback? onReject;

  const PendingProviderCard({
    super.key,
    required this.request,
    required this.token,
    required this.onApproveBackground,
    required this.onReject,
  });

  @override
  State<PendingProviderCard> createState() => _PendingProviderCardState();
}

class _PendingProviderCardState extends State<PendingProviderCard> {
  late bool _canApproveBackground;

  @override
  void initState() {
    super.initState();
    _canApproveBackground = widget.request['documents_verified'] == true;
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final name = req['name']?.toString() ?? 'User';
    final email = req['email']?.toString() ?? '-';
    final phone = req['phone']?.toString() ?? '-';
    final city = req['city']?.toString() ?? '-';
    final area = req['area']?.toString() ?? '-';
    final pincode = req['pincode']?.toString() ?? '-';
    final experience = req['experience_years']?.toString() ?? '-';
    final docsVerifiedFromServer = req['documents_verified'] == true;

    return GlassCard(
      tintColor: AppColors.accentBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: AppTextStyles.heading3)),
              const AdminStatusChip(label: 'Pending', color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 6),
          Text('Email: $email', style: AppTextStyles.bodyMedium),
          Text('Phone: $phone', style: AppTextStyles.bodyMedium),
          Text('Location: $city, $area ($pincode)',
              style: AppTextStyles.bodyMedium),
          Text('Experience: $experience years',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          AdminStepFlowIndicator(
            step1Done: _canApproveBackground,
            step2Done: false,
            step3Done: false,
          ),
          const SizedBox(height: 16),
          PendingProviderDocsPanel(
            request: req,
            token: widget.token,
            docsVerifiedFromServer: docsVerifiedFromServer,
            canApproveBackground: _canApproveBackground,
            onDocsStateChanged: (canApprove) {
              if (_canApproveBackground != canApprove) {
                setState(() => _canApproveBackground = canApprove);
              }
            },
          ),
          const Divider(height: 28),
          const AdminSectionHeader(
            icon: Icons.security_rounded,
            label: 'Step 2 — Approve Background Check',
          ),
          const SizedBox(height: 10),
          if (!_canApproveBackground)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Approve all documents first to enable this step.',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onReject,
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _canApproveBackground
                      ? widget.onApproveBackground
                      : null,
                  icon: const Icon(Icons.verified_user_rounded, size: 16),
                  label: const Text('Approve Background Check'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
