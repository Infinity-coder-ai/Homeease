import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/booking_history_provider.dart';
import '../../providers/rating_refresh_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  Future<void> _cancelBooking({
    required BuildContext context,
    required WidgetRef ref,
    required int bookingId,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final token = ref.read(userProvider).token ?? '';
    if (token.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please login to continue.')),
      );
      return;
    }

    final result = await ApiService.cancelBooking(token: token, bookingId: bookingId);
    if (!context.mounted) return;

    if (result['success'] == true) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Booking canceled successfully.')),
      );
      ref.read(bookingHistoryProvider.notifier).fetchBookings();
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Unable to cancel booking.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmCancelBooking({
    required BuildContext context,
    required WidgetRef ref,
    required int bookingId,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: const Text('This booking will be canceled for both sides.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep booking'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cancelBooking(context: context, ref: ref, bookingId: bookingId);
    }
  }

  void _showBookingActionsSheet({
    required BuildContext context,
    required WidgetRef ref,
    required int bookingId,
    required bool canCancel,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Booking Options', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            if (canCancel)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _confirmCancelBooking(
                    context: context,
                    ref: ref,
                    bookingId: bookingId,
                  );
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel booking'),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No actions available for this booking.',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        final filled = index < rating;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          color: AppColors.accentAmber,
          size: 18,
        );
      }),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return AppColors.success;
      case 'CANCELLED':
        return AppColors.error;
      case 'COMPLETED':
        return AppColors.tertiary;
      default:
        return AppColors.warning;
    }
  }

  Future<void> _showRatingDialog({
    required BuildContext context,
    required WidgetRef ref,
    required int bookingId,
  }) async {
    int selectedRating = 5;
    final reviewCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rate Provider'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: selectedRating,
                decoration: const InputDecoration(labelText: 'Rating'),
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text('${index + 1} Star${index == 0 ? '' : 's'}'),
                  ),
                ),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedRating = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: reviewCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Review (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = ref.read(userProvider).token ?? '';
              if (token.isEmpty) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please login to continue.')),
                );
                return;
              }
              final result = await ApiService.submitRating(
                token: token,
                bookingId: bookingId,
                rating: selectedRating,
                review: reviewCtrl.text.trim().isEmpty
                    ? null
                    : reviewCtrl.text.trim(),
              );
              if (!context.mounted) return;
              Navigator.pop(ctx);
              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thanks for your rating!')),
                );
                ref.read(ratingRefreshProvider.notifier).state++;
                ref.read(bookingHistoryProvider.notifier).fetchBookings();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['message']?.toString() ??
                          'Unable to submit rating.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingHistoryProvider);

    Widget content;

    if (state.isLoading) {
      content = const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    } else if (state.errorMessage != null) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 56),
            const SizedBox(height: AppSpacing.md),
            Text(
              state.errorMessage!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () =>
                  ref.read(bookingHistoryProvider.notifier).fetchBookings(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (state.bookings.isEmpty) {
      content = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 180,
              child: Image(
                image: AssetImage('assets/Empty state.jpg'),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text('No bookings yet', style: AppTextStyles.bodyMedium),
            SizedBox(height: AppSpacing.xs),
            Text('Book a service to see it here', style: AppTextStyles.hint),
          ],
        ),
      );
    } else {
      final user = ref.watch(userProvider);
      content = ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: state.bookings.length,
        itemBuilder: (context, index) {
          final booking = state.bookings[index] as Map<String, dynamic>;
          final status = (booking['status'] ?? 'REQUESTED').toString();
          final isCompleted = status.toUpperCase() == 'COMPLETED';
          final isCancelable = status.toUpperCase() == 'REQUESTED' || status.toUpperCase() == 'ACCEPTED';
          final canceledBy = booking['canceled_by']?.toString();
          final price = booking['price'];
          final priceText = price is num ? 'Rs ${price.toStringAsFixed(0)}' : 'Rs -';
          final date = booking['booking_date']?.toString() ?? '';
          final startTime = booking['start_time']?.toString() ?? '';
          final endTime = booking['end_time']?.toString() ?? '';
          final serviceName = booking['service_name']?.toString() ?? 'Service';
          final providerName = booking['provider_name']?.toString() ?? 'Provider';
          final bookingId = booking['id'] as int?;
          final ratingValue = booking['rating'] as int?;
          final reviewText = booking['review']?.toString().trim();
          final hasRating = ratingValue != null;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: GlassCard(
              tintColor: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        // Top-left menu keeps the card compact and easy to scan.
                        icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textMedium),
                        onPressed: bookingId == null
                            ? null
                            : () => _showBookingActionsSheet(
                                  context: context,
                                  ref: ref,
                                  bookingId: bookingId,
                                  canCancel: isCancelable,
                                ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          serviceName,
                          style: AppTextStyles.heading3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _statusColor(status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Provider: $providerName',
                      style: AppTextStyles.bodyMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 16, color: AppColors.textMedium),
                      const SizedBox(width: 6),
                      Text(date, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 16, color: AppColors.textMedium),
                      const SizedBox(width: 6),
                      Text('$startTime - $endTime',
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Text('Price', style: AppTextStyles.label),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          priceText,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isCompleted && hasRating) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _buildRatingStars(ratingValue),
                        const SizedBox(width: 8),
                        Text(
                          'Your rating: $ratingValue/5',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                    if (reviewText != null && reviewText.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        reviewText,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ],
                  if (status.toUpperCase() == 'CANCELED' && canceledBy != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      canceledBy == 'CUSTOMER'
                          ? 'Canceled by you'
                          : 'Canceled by provider',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (isCompleted && bookingId != null && !hasRating) ...[
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: user.token == null
                            ? null
                            : () => _showRatingDialog(
                                  context: context,
                                  ref: ref,
                                  bookingId: bookingId,
                                ),
                        child: const Text('Rate Provider'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        title: const Text('My Bookings', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SafeArea(child: content),
    );
  }
}
