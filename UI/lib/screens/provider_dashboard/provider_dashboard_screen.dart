import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../notifications/notification_center_screen.dart';
import 'provider_availability_screen.dart';
import 'provider_bookings_screen.dart';
import 'provider_documents_screen.dart';
import 'provider_services_screen.dart';
import 'utils/dashboard_formatters.dart';
import 'widgets/dashboard_booking_preview.dart';
import 'widgets/dashboard_hero_trust.dart';
import 'widgets/dashboard_metrics_actions.dart';
import 'widgets/dashboard_panels.dart';
import 'widgets/dashboard_top_bar.dart';

/// Provider home tab: stats, quick actions, and today's bookings preview.
class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P';
    final unreadNotifications = ref.watch(notificationProvider).items.where((item) {
      return item.audience == NotificationAudience.both ||
          item.audience == NotificationAudience.provider;
    }).where((item) => item.isUnread).length;

    return SafeArea(
      child: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getProviderStats(token: user.token ?? ''),
        builder: (context, snapshot) {
          final stats = snapshot.data?['data'] as Map<String, dynamic>?;
          final trustScore = formatDashboardNumber(stats?['trust_score'], fallback: '0.0');
          final jobs = formatDashboardNumber(stats?['total_jobs_completed'], fallback: '0');
          final cancels = formatDashboardNumber(stats?['total_cancellations'], fallback: '0');
          final verification = stats?['verification_status']?.toString() ?? 'PENDING';
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            children: [
              DashboardTopBar(
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
              const SizedBox(height: 14),
              DashboardHeroCard(
                name: user.name.isNotEmpty ? user.name : 'Provider',
                subtitle: verification == 'APPROVED'
                    ? 'Verified service provider'
                    : 'Application under review',
                initials: initials,
              ),
              const SizedBox(height: 12),
              DashboardTrustCard(
                score: trustScore,
                verification: verification,
                isLoading: isLoading,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: DashboardMetricTile(label: 'Jobs\nCompleted', value: jobs)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DashboardMetricTile(
                      label: 'Profile\nStatus',
                      value: verification == 'APPROVED' ? 'OK' : 'Review',
                      valueColor: verification == 'APPROVED'
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DashboardMetricTile(
                      label: 'Cancellations',
                      value: cancels,
                      valueColor: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DashboardMetricTile(
                      label: 'Rating',
                      value: trustScore,
                      suffix: Icons.star_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text('Manage Workspace', style: AppTextStyles.heading3),
                  ),
                  Text(
                    verification,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DashboardActionGrid(
                items: [
                  DashboardActionItem(
                    title: 'Services',
                    subtitle: 'Pricing',
                    icon: Icons.widgets_rounded,
                    color: AppColors.primary,
                    onTap: () => _push(context, const ProviderServicesScreen()),
                  ),
                  DashboardActionItem(
                    title: 'Availability',
                    subtitle: 'Schedule',
                    icon: Icons.event_available_rounded,
                    color: AppColors.success,
                    onTap: () => _push(context, const ProviderAvailabilityScreen()),
                  ),
                  DashboardActionItem(
                    title: 'Documents',
                    subtitle: 'Verification',
                    icon: Icons.badge_rounded,
                    color: const Color(0xFF3A76FF),
                    onTap: () => _push(context, const ProviderDocumentsScreen()),
                  ),
                  DashboardActionItem(
                    title: 'Bookings',
                    subtitle: 'Requests',
                    icon: Icons.shopping_bag_rounded,
                    color: AppColors.warning,
                    onTap: () => _push(context, const ProviderBookingsScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Today\'s Bookings', style: AppTextStyles.heading3),
              const SizedBox(height: 10),
              _TodayBookingsSection(token: user.token ?? ''),
            ],
          );
        },
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _TodayBookingsSection extends StatelessWidget {
  final String token;

  const _TodayBookingsSection({required this.token});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getProviderBookings(token: token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const DashboardPanelLoading();
        }
        final result = snapshot.data ?? {};
        if (result['success'] != true) {
          return DashboardEmptyPanel(
            icon: Icons.event_note_rounded,
            text: result['message']?.toString() ?? 'Unable to load bookings.',
          );
        }
        final bookings = (result['data'] as List<dynamic>).take(2).toList();
        if (bookings.isEmpty) {
          return const DashboardEmptyPanel(
            icon: Icons.event_note_rounded,
            text: 'No provider bookings yet.',
          );
        }
        return Column(
          children: bookings.map((booking) {
            final map = booking as Map<String, dynamic>;
            final location = [
              map['address']?.toString() ?? '',
              map['city']?.toString() ?? '',
            ].where((part) => part.trim().isNotEmpty).join(', ');
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DashboardBookingPreview(
                customer: map['customer_name']?.toString() ?? 'Customer',
                time: '${map['start_time'] ?? ''} - ${map['end_time'] ?? ''}',
                location: location.isEmpty ? 'Address not shared' : location,
                status: map['status']?.toString() ?? 'REQUESTED',
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
