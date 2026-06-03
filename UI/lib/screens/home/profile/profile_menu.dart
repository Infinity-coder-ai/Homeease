import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// One row in the profile settings menu.
class ProfileMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// White card listing profile shortcuts (bookings, help, notifications).
class ProfileMenuCard extends StatelessWidget {
  final List<ProfileMenuItem> items;

  const ProfileMenuCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final showDivider = index != items.length - 1;
            return Column(
              children: [
                InkWell(
                  onTap: item.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textLight,
                        ),
                      ],
                    ),
                  ),
                ),
                if (showDivider)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.textLight.withValues(alpha: 0.18),
                    indent: 70,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
