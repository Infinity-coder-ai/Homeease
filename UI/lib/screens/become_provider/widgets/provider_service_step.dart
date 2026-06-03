import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'provider_step_header.dart';

class ProviderServiceStep extends StatelessWidget {
  final List<dynamic> services;
  final int? selectedServiceId;
  final void Function(int? value) onSelectService;
  final TextEditingController priceController;
  final TextEditingController durationController;

  const ProviderServiceStep({
    super.key,
    required this.services,
    required this.selectedServiceId,
    required this.onSelectService,
    required this.priceController,
    required this.durationController,
  });

  IconData _iconForService(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('clean')) return Icons.cleaning_services_rounded;
    if (lower.contains('elect')) return Icons.electrical_services_rounded;
    if (lower.contains('paint')) return Icons.format_paint_rounded;
    if (lower.contains('plumb')) return Icons.plumbing_rounded;
    if (lower.contains('repair')) return Icons.handyman_rounded;
    if (lower.contains('beauty')) return Icons.spa_rounded;
    return Icons.miscellaneous_services_rounded;
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
            title: 'Select Your Service',
            subtitle: 'Choose the service you provide.',
          ),
          const SizedBox(height: AppSpacing.lg),
          ...services.map((service) {
            final id = service['id'] as int;
            final name = service['name']?.toString() ?? '';
            final selected = selectedServiceId == id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelectService(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary.withValues(alpha: 0.08) : const Color(0xFFF8F8FB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? AppColors.primary.withValues(alpha: 0.35) : const Color(0xFFE8EAF1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F000000),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _iconForService(name),
                          size: 20,
                          color: selected ? Colors.white : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Icon(
                        selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: selected ? AppColors.primary : AppColors.textLight,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Form(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (Rs)',
                    prefixIcon: Icon(Icons.currency_rupee_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Price is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Estimated duration (hours)',
                    prefixIcon: Icon(Icons.schedule_rounded),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
