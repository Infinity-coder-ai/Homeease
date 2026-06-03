import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/user_provider.dart';
import '../../../theme/app_theme.dart';
import '../../bookings/booking_history_screen.dart';
import '../../login/login_screen.dart';
import '../../notifications/notification_center_screen.dart';
import '../../support/help_support_screen.dart';
import 'profile_header_card.dart';
import 'profile_menu.dart';
import 'profile_provider_section.dart';

/// Profile tab content inside [HomeScreen].
class HomeProfilePage extends ConsumerWidget {
  /// Resets bottom nav to Home when provider mode is toggled.
  final VoidCallback? onProviderModeChanged;

  const HomeProfilePage({super.key, this.onProviderModeChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeaderCard(user: user),
            const SizedBox(height: 18),
            ProfileMenuCard(
              items: [
                ProfileMenuItem(
                  icon: Icons.calendar_month_outlined,
                  label: 'My Bookings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookingHistoryScreen(),
                      ),
                    );
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifications',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationCenterScreen(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ProfileProviderSection(onProviderModeChanged: onProviderModeChanged),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(userProvider.notifier).logout();
                if (!context.mounted) return;
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
