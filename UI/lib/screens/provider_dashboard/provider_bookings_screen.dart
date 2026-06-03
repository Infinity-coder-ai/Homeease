import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/provider_bookings_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ProviderBookingsScreen extends ConsumerStatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  ConsumerState<ProviderBookingsScreen> createState() =>
      _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends ConsumerState<ProviderBookingsScreen> {
  int _tabIndex = 0;

  List<Map<String, dynamic>> _filteredBookings(List<dynamic> bookings) {
    return bookings
        .cast<Map<String, dynamic>>()
        .where((booking) {
          final status = booking['status']?.toString() ?? 'REQUESTED';
          if (_tabIndex == 0) {
            return status == 'REQUESTED' || status == 'ACCEPTED' || status == 'IN_PROGRESS';
          }
          if (_tabIndex == 1) return status == 'COMPLETED';
          return status == 'CANCELED';
        })
        .toList();
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open phone dialer.')),
    );
  }

  Future<void> _performAction({
    required String label,
    required Future<Map<String, dynamic>> Function() action,
  }) async {
    final result = await action();
    if (!mounted) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label successful')),
      );
      ref.read(providerBookingsProvider.notifier).fetchBookings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']?.toString() ?? 'Action failed.')),
      );
    }
  }

  void _showActions(Map<String, dynamic> booking) {
    final bookingId = booking['id'] as int?;
    if (bookingId == null) return;
    final status = booking['status']?.toString() ?? 'REQUESTED';
    final token = ref.read(userProvider).token ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Booking Actions', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text('Current status: $status', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            if (status == 'REQUESTED') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _performAction(
                    label: 'Accept',
                    action: () => ApiService.acceptBooking(
                      token: token,
                      bookingId: bookingId,
                    ),
                  );
                },
                child: const Text('Accept Booking'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _performAction(
                    label: 'Cancel',
                    action: () => ApiService.cancelBooking(
                      token: token,
                      bookingId: bookingId,
                    ),
                  );
                },
                child: const Text('Cancel Booking'),
              ),
            ] else if (status == 'ACCEPTED') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _performAction(
                    label: 'Complete',
                    action: () => ApiService.completeBooking(
                      token: token,
                      bookingId: bookingId,
                    ),
                  );
                },
                child: const Text('Mark Completed'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _performAction(
                    label: 'Cancel',
                    action: () => ApiService.cancelBooking(
                      token: token,
                      bookingId: bookingId,
                    ),
                  );
                },
                child: const Text('Cancel Booking'),
              ),
            ] else
              const Text('No actions available for this booking.', style: AppTextStyles.hint),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(providerBookingsProvider);
    final filtered = _filteredBookings(bookingState.bookings);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FB),
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text('My Bookings', style: AppTextStyles.heading3),
      ),
      body: SafeArea(
        child: bookingState.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : bookingState.errorMessage != null
                ? _StateMessage(
                    icon: Icons.error_outline_rounded,
                    text: bookingState.errorMessage!,
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                        child: _BookingTabs(
                          selectedIndex: _tabIndex,
                          onChanged: (value) => setState(() => _tabIndex = value),
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => ref
                              .read(providerBookingsProvider.notifier)
                              .fetchBookings(),
                          child: filtered.isEmpty
                              ? ListView(
                                  padding: const EdgeInsets.all(24),
                                  children: const [
                                    SizedBox(height: 120),
                                    _StateMessage(
                                      icon: Icons.event_note_rounded,
                                      text: 'No bookings in this section.',
                                    ),
                                  ],
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final booking = filtered[index];
                                    return _BookingCard(
                                      booking: booking,
                                      onActions: () => _showActions(booking),
                                      onCall: () {
                                        final phone =
                                            booking['customer_phone']?.toString() ?? '';
                                        if (phone.isNotEmpty) _callPhone(phone);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _BookingTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _BookingTabs({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const labels = ['Upcoming', 'Completed', 'Cancelled'];
    return Row(
      children: List.generate(labels.length, (index) {
        final selected = index == selectedIndex;
        return Expanded(
          child: InkWell(
            onTap: () => onChanged(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text(
                    labels[index],
                    style: TextStyle(
                      color: selected ? AppColors.primary : AppColors.textMedium,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 2,
                    width: selected ? 64 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onActions;
  final VoidCallback onCall;

  const _BookingCard({
    required this.booking,
    required this.onActions,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final status = booking['status']?.toString() ?? 'REQUESTED';
    final canceledBy = booking['canceled_by']?.toString();
    final date = booking['booking_date']?.toString() ?? '';
    final start = booking['start_time']?.toString() ?? '';
    final end = booking['end_time']?.toString() ?? '';
    final price = booking['price'];
    final priceText = price is num ? 'Rs ${price.toStringAsFixed(0)}' : 'Rs -';
    final customer = booking['customer_name']?.toString() ?? 'Customer';
    final phone = booking['customer_phone']?.toString() ?? '';
    final address = [
      booking['address']?.toString() ?? '',
      booking['city']?.toString() ?? '',
    ].where((part) => part.trim().isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.cleaning_services_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text('$date, $start - $end', style: AppTextStyles.hint),
                    const SizedBox(height: 4),
                    Text(
                      address.isEmpty ? 'Address not shared' : address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.hint,
                    ),
                  ],
                ),
              ),
              Text(
                priceText,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatusPill(status: status),
              const Spacer(),
              if (phone.isNotEmpty)
                IconButton(
                  onPressed: onCall,
                  icon: const Icon(Icons.call_rounded, color: AppColors.primary),
                  tooltip: 'Call customer',
                ),
              IconButton(
                onPressed: onActions,
                icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textMedium),
                tooltip: 'Actions',
              ),
            ],
          ),
          if (status == 'CANCELED' && canceledBy != null) ...[
            const SizedBox(height: 4),
            Text(
              canceledBy == 'CUSTOMER'
                  ? 'Booking canceled from user side'
                  : 'Booking canceled by provider',
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'COMPLETED' => AppColors.success,
      'CANCELED' => AppColors.error,
      'ACCEPTED' => AppColors.primary,
      _ => AppColors.warning,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StateMessage({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textLight, size: 58),
          const SizedBox(height: 12),
          Text(text, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: const Color(0xFFEDEEF5)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0D000000),
        blurRadius: 14,
        offset: Offset(0, 6),
      ),
    ],
  );
}
