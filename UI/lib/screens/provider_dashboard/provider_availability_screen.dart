import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/provider_availability_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ProviderAvailabilityScreen extends ConsumerStatefulWidget {
  const ProviderAvailabilityScreen({super.key});

  @override
  ConsumerState<ProviderAvailabilityScreen> createState() =>
      _ProviderAvailabilityScreenState();
}

class _ProviderAvailabilityScreenState
    extends ConsumerState<ProviderAvailabilityScreen> {
  String _dayLabel(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day.clamp(0, 6)];
  }

  Future<void> _addSlot() async {
    final token = ref.read(userProvider).token ?? '';
    int selectedDay = 0;

    final day = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pick a day'),
        content: DropdownButtonFormField<int>(
          initialValue: selectedDay,
          items: const [
            DropdownMenuItem(value: 0, child: Text('Monday')),
            DropdownMenuItem(value: 1, child: Text('Tuesday')),
            DropdownMenuItem(value: 2, child: Text('Wednesday')),
            DropdownMenuItem(value: 3, child: Text('Thursday')),
            DropdownMenuItem(value: 4, child: Text('Friday')),
            DropdownMenuItem(value: 5, child: Text('Saturday')),
            DropdownMenuItem(value: 6, child: Text('Sunday')),
          ],
          onChanged: (value) => selectedDay = value ?? 0,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, selectedDay),
            child: const Text('Select'),
          ),
        ],
      ),
    );
    if (day == null) return;

    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (start == null) return;

    final end = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (end == null) return;

    await ApiProviderService.createProviderAvailability(
      token: token,
      slots: [
        {
          'day_of_week': day,
          'start_time': _formatTime(start),
          'end_time': _formatTime(end),
        }
      ],
    );
    if (mounted) {
      ref.read(providerAvailabilityProvider.notifier).fetchAvailability();
    }
  }

  Future<void> _deleteSlot(int slotId) async {
    final token = ref.read(userProvider).token ?? '';
    final result = await ApiProviderService.deleteProviderAvailability(
      token: token,
      slotId: slotId,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      ref.read(providerAvailabilityProvider.notifier).removeSlotLocally(slotId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Unable to delete slot.'),
        ),
      );
    }
  }

  String _formatTime(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final availabilityState = ref.watch(providerAvailabilityProvider);
    final slots = availabilityState.slots;

    final grouped = <int, List<Map<String, dynamic>>>{};
    for (final item in slots) {
      final slot = item as Map<String, dynamic>;
      final day = slot['day_of_week'] as int? ?? 0;
      grouped.putIfAbsent(day, () => []).add(slot);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Availability', style: AppTextStyles.heading3),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filled(
              onPressed: _addSlot,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: availabilityState.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : availabilityState.errorMessage != null
                ? _StateMessage(
                    icon: Icons.error_outline_rounded,
                    text: availabilityState.errorMessage!,
                  )
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(providerAvailabilityProvider.notifier)
                        .fetchAvailability(),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                      children: [
                        const Text('Set Your Availability', style: AppTextStyles.heading3),
                        const SizedBox(height: 4),
                        const Text(
                          'Let customers know when you are available',
                          style: AppTextStyles.hint,
                        ),
                        const SizedBox(height: 14),
                        _StatusCard(isOnline: slots.isNotEmpty),
                        const SizedBox(height: 18),
                        const Text('Weekly Schedule', style: AppTextStyles.heading3),
                        const SizedBox(height: 10),
                        if (slots.isEmpty)
                          const _StatePanel(
                            icon: Icons.event_busy_rounded,
                            text: 'No availability slots yet.',
                          )
                        else
                          ...List.generate(7, (day) {
                            final daySlots = grouped[day] ?? [];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _DayCard(
                                day: _dayLabel(day),
                                slots: daySlots,
                                onDelete: (slot, slotIndex) {
                                  final slotId = slot['id'] as int?;
                                  if (slotId != null) _deleteSlot(slotId);
                                },
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool isOnline;

  const _StatusCard({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 19),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Working Status', style: AppTextStyles.heading3),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (isOnline ? AppColors.success : AppColors.warning)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isOnline ? 'Online' : 'No Slots',
              style: TextStyle(
                color: isOnline ? AppColors.success : AppColors.warning,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final String day;
  final List<Map<String, dynamic>> slots;
  final void Function(Map<String, dynamic> slot, int slotIndex) onDelete;

  const _DayCard({
    required this.day,
    required this.slots,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final unavailable = slots.isEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Text(day, style: AppTextStyles.heading3),
          ),
          Expanded(
            child: unavailable
                ? const Text(
                    'Unavailable',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: slots.asMap().entries.map((entry) {
                      final slot = entry.value;
                      final start = slot['start_time']?.toString() ?? '';
                      final end = slot['end_time']?.toString() ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                '$start - $end',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => onDelete(slot, entry.key),
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textLight,
                                size: 17,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatePanel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StatePanel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textLight),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
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
          Text(text, style: AppTextStyles.bodyMedium),
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
