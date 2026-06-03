import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/home_navigation_provider.dart';
import '../../providers/user_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../bookings/booking_history_screen.dart';
import '../provider_dashboard/provider_bookings_screen.dart';
import '../provider_dashboard/provider_dashboard_screen.dart';
import 'customer/home_customer_page.dart';
import 'navigation/home_bottom_nav.dart';
import 'profile/home_profile_page.dart';

/// Main shell after login: bottom nav + role-based body (customer or provider).
///
/// File layout:
/// - [customer/home_customer_page.dart] — Home tab for customers
/// - [profile/home_profile_page.dart] — Profile tab
/// - [navigation/home_bottom_nav.dart] — Bottom navigation bar
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final currentIndex = ref.watch(homeTabIndexProvider);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Admins use a separate dashboard, not this shell.
    if (user.role == 'admin') {
      return const AdminDashboardScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: _buildBody(user.providerMode, currentIndex),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: currentIndex,
        onTabSelected: (index) =>
            ref.read(homeTabIndexProvider.notifier).state = index,
      ),
    );
  }

  /// Picks the screen for the selected tab (customer vs provider mode).
  Widget _buildBody(bool providerMode, int currentIndex) {
    void resetToHomeTab() =>
        ref.read(homeTabIndexProvider.notifier).state = 0;

    if (providerMode) {
      switch (currentIndex) {
        case 1:
          return const ProviderBookingsScreen();
        case 2:
          return HomeProfilePage(onProviderModeChanged: resetToHomeTab);
        default:
          return const ProviderDashboardScreen();
      }
    }

    switch (currentIndex) {
      case 1:
        return const BookingHistoryScreen();
      case 2:
        return HomeProfilePage(onProviderModeChanged: resetToHomeTab);
      default:
        return const HomeCustomerPage();
    }
  }
}
