import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Promotional banner on the customer home tab (discount + Book Now CTA).
class HomePromoCard extends StatelessWidget {
  final double scale;
  final double promoImageSize;
  final double promoButtonHeight;
  final VoidCallback onBookNow;

  const HomePromoCard({
    super.key,
    required this.scale,
    required this.promoImageSize,
    required this.promoButtonHeight,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16 * scale, 16 * scale, 0, 0),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F7EC),
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16 * scale),
                  ),
                  child: Text(
                    '40% Off',
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                SizedBox(height: 10 * scale),
                Text(
                  'Quick Home\nCleaning Service',
                  style: TextStyle(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  'Fresh, fast & reliable\ncleaning for your home.',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10 * scale),
                  child: SizedBox(
                    height: promoButtonHeight,
                    child: ElevatedButton(
                      onPressed: onBookNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 18 * scale),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18 * scale),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Book Now  →'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 5 * scale),
          Image.asset(
            'assets/dashboard girl.png',
            width: promoImageSize,
            height: promoImageSize,
            alignment: Alignment.bottomRight,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
