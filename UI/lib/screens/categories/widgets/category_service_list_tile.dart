import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/category_service_item.dart';

/// Single service row on [CategoryServicesScreen].
class CategoryServiceListTile extends StatelessWidget {
  final CategoryServiceItem item;
  final double scale;

  const CategoryServiceListTile({
    super.key,
    required this.item,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18 * scale),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12 * scale),
            child: Image.asset(
              item.image,
              width: 86 * scale,
              height: 86 * scale,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 86 * scale,
                height: 86 * scale,
                color: Colors.grey.shade200,
                child: Icon(Icons.image_not_supported, color: Colors.grey, size: 28 * scale),
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textLight, size: 20 * scale),
        ],
      ),
    );
  }
}
