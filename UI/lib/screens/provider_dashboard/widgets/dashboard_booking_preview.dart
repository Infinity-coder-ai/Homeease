import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'dashboard_panels.dart';

/// Compact booking row on the provider home dashboard.
class DashboardBookingPreview extends StatelessWidget {
  final String customer;
  final String time;
  final String location;
  final String status;

  const DashboardBookingPreview({
    super.key,
    required this.customer,
    required this.time,
    required this.location,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardWhitePanel(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.cleaning_services_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer, style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text(time, style: AppTextStyles.hint),
                const SizedBox(height: 2),
                Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.hint,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
