import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class HomeDashboardHeader extends StatelessWidget {
  final String displayName;
  final double scale;
  final double avatarSize;
  final double headerIconSize;
  final double headlineSize;
  final double spacingSm;
  final double spacingMd;
  final int notificationCount;
  final VoidCallback? onNotificationsTap;

  const HomeDashboardHeader({
    super.key,
    required this.displayName,
    required this.scale,
    required this.avatarSize,
    required this.headerIconSize,
    required this.headlineSize,
    required this.spacingSm,
    required this.spacingMd,
    required this.notificationCount,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  displayName[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $displayName 👋',
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    'Good Evening',
                    style: TextStyle(
                      fontSize: 14 * scale,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: spacingSm),
            _roundIconButton(
              Icons.notifications_none_rounded,
              headerIconSize,
              badgeCount: notificationCount,
              onTap: onNotificationsTap,
            ),
          ],
        ),
        SizedBox(height: spacingMd),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Smart Home,\n',
                style: TextStyle(
                  fontSize: headlineSize,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  color: AppColors.textDark,
                ),
              ),
              TextSpan(
                text: 'Smooth Services',
                style: TextStyle(
                  fontSize: headlineSize,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  height: 1.15,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacingMd),
      ],
    );
  }

  Widget _roundIconButton(
    IconData icon,
    double size, {
    int badgeCount = 0,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14 * (size / 40)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14 * (size / 40)),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14 * (size / 40)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, color: AppColors.textDark, size: 20 * (size / 40)),
                ),
              ),
              if (badgeCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
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
        ),
      ),
    );
  }
}
