// One document row with preview image and approve/reject actions.
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/full_screen_image_viewer.dart';

class AdminDocReviewTile extends StatelessWidget {
  final String type;
  final String status;
  final String imageUrl;
  final bool isLoading;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const AdminDocReviewTile({
    super.key,
    required this.type,
    required this.status,
    required this.imageUrl,
    required this.isLoading,
    required this.onApprove,
    required this.onReject,
  });

  Color get _statusColor {
    switch (status) {
      case 'APPROVED':
        return AppColors.success;
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case 'APPROVED':
        return Icons.check_circle_rounded;
      case 'REJECTED':
        return Icons.cancel_rounded;
      default:
        return Icons.pending_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.06),
        border: Border.all(color: _statusColor.withValues(alpha: 0.30)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Icon(_statusIcon, color: _statusColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    type.replaceAll('_', ' '),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: TappableDocumentImage(
                imageUrl: imageUrl,
                title: type,
                height: 160,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReject,
                          icon: const Icon(Icons.close_rounded, size: 15),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(
                              color: onReject == null
                                  ? Colors.grey.shade300
                                  : AppColors.error,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onApprove,
                          icon: const Icon(Icons.check_rounded, size: 15),
                          label: const Text('Approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: onApprove == null
                                ? Colors.grey.shade300
                                : AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
