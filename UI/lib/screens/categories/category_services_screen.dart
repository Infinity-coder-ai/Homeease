import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../provider_search/provider_search_screen.dart';
import 'data/category_services_catalog.dart';
import 'models/category_service_item.dart';
import 'widgets/category_promo_card.dart';
import 'widgets/category_service_list_tile.dart';

/// Lists services for a category (Cleaning, Repairs, etc.) from static catalog data.
class CategoryServicesScreen extends StatelessWidget {
  final String categoryName;

  const CategoryServicesScreen({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 390).clamp(0.85, 1.15);
    final padding = 18 * scale;
    final services = servicesForCategory(categoryName);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(categoryName, style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(padding, 6 * scale, padding, 8 * scale),
              child: CategoryPromoCard(scale: scale),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(padding, 4 * scale, padding, 24 * scale),
                itemCount: services.length,
                separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
                itemBuilder: (context, index) {
                  final item = services[index];
                  return GestureDetector(
                    onTap: () => _openProviderSearch(context, item),
                    child: CategoryServiceListTile(item: item, scale: scale),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProviderSearch(BuildContext context, CategoryServiceItem item) {
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
  }
}
