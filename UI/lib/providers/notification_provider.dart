import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'user_provider.dart';

enum NotificationAudience { customer, provider, both }

enum NotificationKind { booking, payment, request, verification, system }

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final NotificationAudience audience;
  final NotificationKind kind;
  final bool isUnread;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.audience,
    required this.kind,
    required this.isUnread,
  });

  NotificationItem copyWith({bool? isUnread}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      audience: audience,
      kind: kind,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}

class NotificationState {
  final List<NotificationItem> items;
  final int serverUnreadCount;

  const NotificationState({required this.items, this.serverUnreadCount = 0});

  int get unreadCount => items.where((item) => item.isUnread).length;

  NotificationState copyWith({List<NotificationItem>? items, int? serverUnreadCount}) {
    return NotificationState(
      items: items ?? this.items,
      serverUnreadCount: serverUnreadCount ?? this.serverUnreadCount,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final Ref ref;

  NotificationNotifier(this.ref) : super(const NotificationState(items: [])) {
    // Load notifications from backend when notifier is created.
    fetchNotifications();
  }

  // Convert backend payload to local model
  static NotificationKind _kindFromString(String? s) {
    switch (s) {
      case 'booking':
        return NotificationKind.booking;
      case 'payment':
        return NotificationKind.payment;
      case 'request':
        return NotificationKind.request;
      case 'verification':
        return NotificationKind.verification;
      default:
        return NotificationKind.system;
    }
  }

  static NotificationItem _fromMap(Map<String, dynamic> m) {
    final id = (m['id'] ?? '').toString();
    final title = (m['title'] ?? '') as String;
    final body = (m['message'] ?? '') as String;
    final createdAtRaw = m['created_at']?.toString() ?? '';
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(createdAtRaw);
    } catch (_) {
      createdAt = DateTime.now();
    }
    final isRead = (m['is_read'] ?? false) as bool;

    return NotificationItem(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      audience: NotificationAudience.both,
      kind: _kindFromString(m['category']?.toString()),
      isUnread: !isRead,
    );
  }

  Future<void> fetchNotifications({
    bool unreadOnly = false,
    bool refreshUnreadCount = true,
  }) async {
    final token = ref.read(userProvider).token ?? '';
    if (token.isEmpty) return;

    final res = await ApiService.getNotifications(token: token, unreadOnly: unreadOnly);
    if (res['success'] == true) {
      final data = res['data'] as List<dynamic>;
      final items = data.map((e) => _fromMap(e as Map<String, dynamic>)).toList();
      state = state.copyWith(items: items);
      // Update server unread count after fetching list unless the caller wants
      // to suppress it for a local-only badge reset.
      if (refreshUnreadCount) {
        fetchUnreadCount();
      }
    }
  }

  Future<void> fetchUnreadCount() async {
    final token = ref.read(userProvider).token ?? '';
    if (token.isEmpty) return;

    final res = await ApiService.getUnreadNotificationsCount(token: token);
    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      final count = (data['unread_count'] ?? 0) as int;
      state = state.copyWith(serverUnreadCount: count);
    }
  }

  void markRead(String id) {
    // Optimistic local update; also call backend if available.
    state = state.copyWith(
      items: state.items
          .map((item) => item.id == id ? item.copyWith(isUnread: false) : item)
          .toList(),
    );

    final token = ref.read(userProvider).token ?? '';
    if (token.isNotEmpty) {
      final intId = int.tryParse(id) ?? -1;
      if (intId > 0) ApiService.markNotificationRead(token: token, id: intId);
      // Refresh server unread count to keep badge in sync
      fetchUnreadCount();
    }
  }

  void markAllRead() {
    state = state.copyWith(
      items: state.items.map((item) => item.copyWith(isUnread: false)).toList(),
    );

    final token = ref.read(userProvider).token ?? '';
    if (token.isNotEmpty) ApiService.markAllNotificationsRead(token: token);
    // After marking all read, clear server count locally
    state = state.copyWith(serverUnreadCount: 0);
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
  (ref) => NotificationNotifier(ref),
);