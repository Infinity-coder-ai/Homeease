import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Promo banner at the top of [CategoryServicesScreen].
class CategoryPromoCard extends StatelessWidget {
  final double scale;

  const CategoryPromoCard({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 10 * scale, 14 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E8DD),
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get 20% Off',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  'on Home Cleaning',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  'Book professional cleaning\nat your convenience.',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    color: AppColors.textMedium,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 10 * scale),
                SizedBox(
                  height: 30 * scale,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                      textStyle: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * scale),
          Image.asset(
            'assets/dashboard girl.png',
            width: 110 * scale,
            height: 110 * scale,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) => Container(
              width: 110 * scale,
              height: 110 * scale,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Icon(Icons.image_not_supported, color: Colors.grey, size: 36 * scale),
            ),
          ),
        ],
      ),
    );
  }
}
