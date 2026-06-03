import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/notification_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/notification_center_widgets.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends ConsumerState<NotificationCenterScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifications = ref.read(notificationProvider.notifier);
      await notifications.fetchNotifications(refreshUnreadCount: false);
      notifications.markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final state = ref.watch(notificationProvider);
    final audience = user.isProvider ? NotificationAudience.provider : NotificationAudience.customer;
    final visibleItems = _visibleItems(state.items, audience);
    final unreadCount = visibleItems.where((item) => item.isUnread).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        centerTitle: true,
        title: const Text('Notifications', style: AppTextStyles.heading3),
        actions: [
          TextButton(
            onPressed: unreadCount == 0
                ? null
                : () => ref.read(notificationProvider.notifier).markAllRead(),
            child: const Text('Mark all read'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            NotificationSummaryCard(
              title: user.isProvider ? 'Provider inbox' : 'Customer inbox',
              subtitle: user.isProvider
                  ? 'Track booking requests, approvals, and account updates in one place.'
                  : 'Follow your bookings, payment updates, and service messages here.',
              unreadCount: unreadCount,
              chipLabel: user.isProvider ? 'Provider mode' : 'Customer view',
            ),
            const SizedBox(height: 16),
            NotificationFilterRow(
              filter: _filter,
              onChanged: (value) => setState(() => _filter = value),
            ),
            const SizedBox(height: 16),
            if (visibleItems.isEmpty)
              const NotificationEmptyState()
            else
              ...visibleItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NotificationCard(
                    item: item,
                    onTap: () => ref.read(notificationProvider.notifier).markRead(item.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<NotificationItem> _visibleItems(
    List<NotificationItem> items,
    NotificationAudience audience,
  ) {
    final roleFiltered = items.where((item) {
      return item.audience == NotificationAudience.both || item.audience == audience;
    }).toList();
    if (_filter == 'unread') {
      return roleFiltered.where((item) => item.isUnread).toList();
    }
    return roleFiltered;
  }
}