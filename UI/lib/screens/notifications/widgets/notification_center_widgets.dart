import 'package:flutter/material.dart';

import '../../../providers/notification_provider.dart';
import '../../../theme/app_theme.dart';

class NotificationSummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int unreadCount;
  final String chipLabel;

  const NotificationSummaryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.unreadCount,
    required this.chipLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.card.copyWith(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF0EEFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTextStyles.heading2)),
              NotificationCountBadge(count: unreadCount),
            ],
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: NotificationModeChip(label: chipLabel),
          ),
        ],
      ),
    );
  }
}

class NotificationFilterRow extends StatelessWidget {
  final String filter;
  final ValueChanged<String> onChanged;

  const NotificationFilterRow({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const filters = [
      ('all', 'All'),
      ('unread', 'Unread'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(entry.$2),
                  selected: filter == entry.$1,
                  onSelected: (_) => onChanged(entry.$1),
                  selectedColor: AppColors.primaryLight,
                  labelStyle: TextStyle(
                    color: filter == entry.$1 ? AppColors.primaryDark : AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  side: BorderSide(
                    color: filter == entry.$1 ? AppColors.primary : AppColors.inputBorder,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _metaFor(item.kind);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.card.copyWith(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: meta.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(meta.icon, color: meta.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTextStyles.heading3,
                          ),
                        ),
                        if (item.isUnread)
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item.body, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (meta.label.toLowerCase() != 'system') ...[
                          NotificationModeChip(label: meta.label),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _timeAgo(item.createdAt),
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 34),
      decoration: AppDecorations.card,
      child: const Column(
        children: [
          Icon(Icons.notifications_none_rounded, size: 54, color: AppColors.textLight),
          SizedBox(height: 14),
          Text('No notifications here yet', style: AppTextStyles.heading3),
          SizedBox(height: 8),
          Text(
            'When something changes, it will appear here immediately.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class NotificationModeChip extends StatelessWidget {
  final String label;

  const NotificationModeChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class NotificationCountBadge extends StatelessWidget {
  final int count;

  const NotificationCountBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count unread',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NotificationMeta {
  final IconData icon;
  final Color color;
  final String label;

  const _NotificationMeta({
    required this.icon,
    required this.color,
    required this.label,
  });
}

_NotificationMeta _metaFor(NotificationKind kind) {
  return switch (kind) {
    NotificationKind.booking => const _NotificationMeta(
        icon: Icons.event_available_rounded,
        color: AppColors.primaryDark,
        label: 'Booking',
      ),
    NotificationKind.payment => const _NotificationMeta(
        icon: Icons.account_balance_wallet_rounded,
        color: AppColors.success,
        label: 'Payment',
      ),
    NotificationKind.request => const _NotificationMeta(
        icon: Icons.assignment_turned_in_rounded,
        color: AppColors.warning,
        label: 'Request',
      ),
    NotificationKind.verification => const _NotificationMeta(
        icon: Icons.verified_rounded,
        color: Color(0xFF3A76FF),
        label: 'Verification',
      ),
    NotificationKind.system => const _NotificationMeta(
        icon: Icons.info_outline_rounded,
        color: AppColors.textLight,
        label: 'System',
      ),
  };
}

String _timeAgo(DateTime time) {
  final difference = DateTime.now().difference(time);
  if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes.clamp(1, 59);
    return '$minutes min ago';
  }
  if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours hr ago';
  }
  final days = difference.inDays;
  return '$days day${days == 1 ? '' : 's'} ago';
}
