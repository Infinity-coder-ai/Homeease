import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Header row with logo and notification bell.
class DashboardTopBar extends StatelessWidget {
  final int notificationCount;
  final VoidCallback? onNotificationsTap;

  const DashboardTopBar({
    super.key,
    required this.notificationCount,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.home_rounded, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        const Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Home', style: TextStyle(color: AppColors.textDark)),
                TextSpan(text: 'Ease', style: TextStyle(color: AppColors.primary)),
              ],
            ),
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: onNotificationsTap,
              icon: const Icon(Icons.notifications_none_rounded),
              color: AppColors.textDark,
            ),
            if (notificationCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    notificationCount > 9 ? '9+' : '$notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
