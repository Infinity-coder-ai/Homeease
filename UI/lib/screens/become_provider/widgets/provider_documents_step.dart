import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'provider_step_header.dart';

class ProviderDocumentsStep extends StatelessWidget {
  final String? profilePhotoName;
  final String? idProofName;
  final VoidCallback onPickProfile;
  final VoidCallback onPickIdProof;

  const ProviderDocumentsStep({
    super.key,
    required this.profilePhotoName,
    required this.idProofName,
    required this.onPickProfile,
    required this.onPickIdProof,
  });

  IconData _docIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('profile')) return Icons.person_rounded;
    return Icons.badge_rounded;
  }

  Widget _docTile({
    required String title,
    required String subtitle,
    required VoidCallback onPick,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAF1)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_docIcon(title), color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.hint),
              ],
            ),
          ),
          TextButton(
            onPressed: onPick,
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProviderStepHeader(
            title: 'Upload Documents',
            subtitle: 'Please upload clear photos of the documents.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _docTile(
            title: 'Profile photo',
            subtitle: profilePhotoName ?? 'Add your photo',
            onPick: onPickProfile,
          ),
          const SizedBox(height: AppSpacing.md),
          _docTile(
            title: 'Aadhaar Card',
            subtitle: idProofName ?? 'Upload Aadhaar card',
            onPick: onPickIdProof,
          ),
        ],
      ),
    );
  }
}
