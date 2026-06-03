import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/user_provider.dart';
import '../../categories/all_categories_screen.dart';
import '../../categories/category_services_screen.dart';
import '../../notifications/notification_center_screen.dart';
import '../utils/home_responsive.dart';
import '../widgets/become_provider.dart';
import '../widgets/home_category_strip.dart';
import '../widgets/home_dashboard_header.dart';
import '../widgets/home_popular_services.dart';
import '../widgets/home_promo_card.dart';
import '../widgets/home_search_bar.dart';

/// Scrollable customer home tab (header, search, categories, promo, popular).
class HomeCustomerPage extends ConsumerWidget {
  const HomeCustomerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final displayName = user.name.isNotEmpty ? user.name : 'Anna';
    final unreadNotifications = ref.watch(notificationProvider).serverUnreadCount;
    final layout = HomeResponsive.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: layout.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeDashboardHeader(
              displayName: displayName,
              scale: layout.scale,
              avatarSize: layout.avatarSize,
              headerIconSize: layout.headerIconSize,
              headlineSize: layout.headlineSize,
              spacingSm: layout.spacingSm,
              spacingMd: layout.spacingMd,
              notificationCount: unreadNotifications,
              onNotificationsTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationCenterScreen(),
                  ),
                );
              },
            ),
            const HomeSearchBar(),
            SizedBox(height: layout.spacingMd),
            HomeCategoryStrip(
              scale: layout.scale,
              onTap: (serviceId, label) => _onCategoryTap(context, serviceId, label),
            ),
            SizedBox(height: layout.spacingMd),
            HomePromoCard(
              scale: layout.scale,
              promoImageSize: layout.promoImageSize,
              promoButtonHeight: layout.promoButtonHeight,
              onBookNow: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategoryServicesScreen(
                      categoryName: 'Cleaning',
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20 * layout.scale),
            HomePopularServices(
              scale: layout.scale,
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AllCategoriesScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 24 * layout.scale),
            const BecomeProvider(),
            SizedBox(height: 24 * layout.scale),
          ],
        ),
      ),
    );
  }

  void _onCategoryTap(BuildContext context, int serviceId, String label) {
    if (serviceId <= 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AllCategoriesScreen()),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryServicesScreen(categoryName: label),
      ),
    );
  }
}
