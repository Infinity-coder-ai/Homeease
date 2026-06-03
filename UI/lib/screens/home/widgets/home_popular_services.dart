import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../provider_search/provider_search_screen.dart';

/// Horizontal list of featured services on the customer home tab.
class HomePopularServices extends StatelessWidget {
  final double scale;
  final VoidCallback? onViewAll;

  const HomePopularServices({
    super.key,
    required this.scale,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Popular Services', style: AppTextStyles.heading3),
            InkWell(
              onTap: onViewAll,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * scale),
        SizedBox(
          height: 168 * scale,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return _PopularServiceCard(item: _popularItems[index]);
            },
            separatorBuilder: (_, __) => SizedBox(width: 12 * scale),
            itemCount: _popularItems.length,
          ),
        ),
      ],
    );
  }
}

/// Static catalog entry for a popular service card (IDs match backend services).
class PopularServiceItem {
  final int serviceId;
  final String title;
  final String price;
  final String image;

  const PopularServiceItem({
    required this.serviceId,
    required this.title,
    required this.price,
    required this.image,
  });
}

class _PopularServiceCard extends StatelessWidget {
  final PopularServiceItem item;

  const _PopularServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 390).clamp(0.85, 1.15);
    final cardWidth = 156 * scale;
    final imageHeight = 100 * scale;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProviderSearchScreen(
              serviceId: item.serviceId,
              serviceName: item.title,
              imageAsset: bannerAssetForService(item.serviceId),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18 * scale),
      child: Container(
        width: cardWidth,
        padding: EdgeInsets.all(10 * scale),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14 * scale),
              child: Image.asset(
                item.image,
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 12.5 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            if (item.price.isNotEmpty) ...[
              SizedBox(height: 4 * scale),
              Text(
                item.price,
                style: TextStyle(
                  fontSize: 11 * scale,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

const List<PopularServiceItem> _popularItems = [
  PopularServiceItem(
    serviceId: 6,
    title: 'Home Cleaning',
    price: '',
    image: 'assets/house cleaning.jpg',
  ),
  PopularServiceItem(
    serviceId: 2,
    title: 'Plumbing',
    price: '',
    image: 'assets/Plumber.jpg',
  ),
  PopularServiceItem(
    serviceId: 1,
    title: 'Electrical',
    price: '',
    image: 'assets/Electrician.jpg',
  ),
];
