import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/availability_slot.dart';
import 'provider_step_header.dart';

class ProviderAvailabilityStep extends StatelessWidget {
  final List<AvailabilitySlot> slots;
  final VoidCallback onAddSlot;
  final void Function(int index) onRemoveSlot;

  const ProviderAvailabilityStep({
    super.key,
    required this.slots,
    required this.onAddSlot,
    required this.onRemoveSlot,
  });

  String _dayLabel(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day.clamp(0, 6)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProviderStepHeader(
            title: 'Availability',
            subtitle: 'Add the time slots when you can take bookings.',
          ),
          const SizedBox(height: AppSpacing.lg),
          if (slots.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8EAF1)),
              ),
              child: const Text('No slots added yet.', style: AppTextStyles.bodyMedium),
            ),
          if (slots.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: slots.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final slot = slots[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8FB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8EAF1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_dayLabel(slot.dayOfWeek)} • ${slot.startTime.format(context)} - ${slot.endTime.format(context)}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: () => onRemoveSlot(index),
                        icon: const Icon(Icons.close_rounded, color: AppColors.error),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: onAddSlot,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Slot'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}
