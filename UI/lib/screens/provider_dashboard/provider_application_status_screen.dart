import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'provider_dashboard_screen.dart';

class ProviderApplicationStatusScreen extends ConsumerWidget {
  const ProviderApplicationStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(userProvider).token ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Application Status', style: AppTextStyles.heading3),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: ApiProviderService.getProviderApplicationStatus(token: token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final result = snapshot.data ?? {};
            if (result['success'] != true) {
              return _MessagePanel(
                text: result['message']?.toString() ?? 'Unable to load status.',
              );
            }

            final data = result['data'] as Map<String, dynamic>;
            if (data['has_application'] != true) {
              return const _MessagePanel(text: 'Provider application not started yet.');
            }

            final appStatus = data['application_status']?.toString() ?? 'PENDING';
            final docsVerified = data['documents_verified'] == true;
            final backgroundVerified = data['background_verified'] == true;
            final role = data['role']?.toString() ?? 'customer';
            final isRoleAssigned = role == 'provider';
            final documentStatus =
                data['document_status'] as Map<String, dynamic>? ?? {};

            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
              children: [
                // ── Step 1: Application Submitted ──────────────────────
                const _TimelineStep(
                  title: 'Application Submitted',
                  subtitle: 'Your provider profile has been created.',
                  state: _StepState.done,
                ),
                // ── Step 2: Document Verification ──────────────────────
                _TimelineStep(
                  title: 'Document Verification',
                  subtitle: docsVerified
                      ? 'All documents approved'
                      : 'Waiting for document review',
                  state: docsVerified ? _StepState.done : _StepState.active,
                ),
                // ── Step 3: Background Verification ────────────────────
                // Marked done when verification_status = APPROVED.
                // Does NOT mean full access; role assignment is still needed.
                _TimelineStep(
                  title: 'Background Verification',
                  subtitle: backgroundVerified
                      ? 'Completed'
                      : appStatus == 'REJECTED'
                          ? 'Rejected'
                          : 'Pending admin review',
                  state: backgroundVerified
                      ? _StepState.done
                      : appStatus == 'REJECTED'
                          ? _StepState.rejected
                          : _StepState.pending,
                ),
                // ── Step 4: Provider Role Assigned ─────────────────────
                // This is the true final step that unlocks the dashboard.
                _TimelineStep(
                  title: 'Provider Role Assigned',
                  subtitle: isRoleAssigned
                      ? 'You now have full provider access'
                      : backgroundVerified
                          ? 'Awaiting final role assignment'
                          : 'Pending',
                  state: isRoleAssigned
                      ? _StepState.done
                      : backgroundVerified
                          ? _StepState.active
                          : _StepState.pending,
                  isLast: true,
                ),
                const SizedBox(height: 18),
                _ReviewCard(
                  appStatus: appStatus,
                  docsVerified: docsVerified,
                  isRoleAssigned: isRoleAssigned,
                  documentStatus: documentStatus,
                  backgroundVerified: backgroundVerified,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isRoleAssigned
                        ? () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProviderDashboardScreen(),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      isRoleAssigned
                          ? 'Go to Provider Dashboard'
                          : 'Waiting for Final Approval',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

enum _StepState { done, active, pending, rejected }

class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final _StepState state;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.state,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _StepState.done => AppColors.success,
      _StepState.active => AppColors.primary,
      _StepState.rejected => AppColors.error,
      _StepState.pending => const Color(0xFFB8BBC7),
    };

    final icon = switch (state) {
      _StepState.done => Icons.check_rounded,
      _StepState.rejected => Icons.close_rounded,
      _ => Icons.circle,
    };

    final iconSize = (state == _StepState.done || state == _StepState.rejected) ? 15.0 : 9.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: iconSize),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: const Color(0xFFDADDE7)),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.heading3),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: state == _StepState.active
                          ? AppColors.primary
                          : state == _StepState.rejected
                              ? AppColors.error
                              : AppColors.textLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String appStatus;
  final bool docsVerified;
  final bool isRoleAssigned;
  final Map<String, dynamic> documentStatus;
  final bool backgroundVerified;

  const _ReviewCard({
    required this.appStatus,
    required this.docsVerified,
    required this.isRoleAssigned,
    required this.documentStatus,
    required this.backgroundVerified,
  });

  @override
  Widget build(BuildContext context) {
    final String headline;
    final String body;
    final Color cardColor;

    if (isRoleAssigned) {
      headline = 'You are now a verified provider!';
      body = 'Your provider role has been assigned. You can now access the provider dashboard.';
      cardColor = AppColors.success;
    } else if (backgroundVerified) {
      headline = 'Background check passed';
      body =
          'Background verification is approved. The final step is for admin to assign your provider role to unlock the dashboard.';
      cardColor = AppColors.primary;
    } else if (appStatus == 'REJECTED') {
      headline = 'Application rejected';
      body = 'Your application was not approved. Please contact support for more information.';
      cardColor = AppColors.error;
    } else {
      headline = 'We are reviewing your application';
      body =
          'Upload required documents and wait for admin to verify them. Background verification starts after documents are approved.';
      cardColor = AppColors.primary;
    }

    // Progress: 0 = no docs, 0.5 = docs verified, 0.75 = bg approved, 1.0 = role assigned
    final double progress = isRoleAssigned
        ? 1.0
        : backgroundVerified
            ? 0.75
            : docsVerified
                ? 0.5
                : 0.25;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(headline, style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 14),
          _DocLine(label: 'Aadhaar Card', status: documentStatus['AADHAAR']),
          const SizedBox(height: 8),
          _DocLine(label: 'Profile Photo', status: documentStatus['PROFILE_PHOTO']),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(cardColor),
            ),
          ),
          const SizedBox(height: 8),
          // Step label
          Text(
            isRoleAssigned
                ? '4 / 4 steps complete'
                : backgroundVerified
                    ? '3 / 4 steps complete'
                    : docsVerified
                        ? '2 / 4 steps complete'
                        : '1 / 4 steps complete',
            style: TextStyle(
              color: cardColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocLine extends StatelessWidget {
  final String label;
  final dynamic status;

  const _DocLine({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final text = status?.toString() ?? 'NOT_UPLOADED';
    final color = text == 'APPROVED'
        ? AppColors.success
        : text == 'REJECTED'
            ? AppColors.error
            : AppColors.warning;
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
        Text(
          text.replaceAll('_', ' '),
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MessagePanel extends StatelessWidget {
  final String text;

  const _MessagePanel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(text, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
      ),
    );
  }
}
