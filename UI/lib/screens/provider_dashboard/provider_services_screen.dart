import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/provider_services_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ProviderServicesScreen extends ConsumerStatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  ConsumerState<ProviderServicesScreen> createState() =>
      _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends ConsumerState<ProviderServicesScreen> {
  Future<void> _showAddService() async {
    final token = ref.read(userProvider).token ?? '';
    final servicesResult = await ApiCatalogService.getServiceCatalog();
    final services = servicesResult['data'] as List<dynamic>? ?? [];

    int? selectedId;
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: selectedId,
                items: services
                    .map((service) => DropdownMenuItem<int>(
                          value: service['id'] as int,
                          child: Text(service['name']?.toString() ?? ''),
                        ))
                    .toList(),
                onChanged: (value) => selectedId = value,
                decoration: const InputDecoration(labelText: 'Service'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (Rs)'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (hours)'),
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
              if (selectedId == null || priceCtrl.text.trim().isEmpty) return;
              final hours = durationCtrl.text.trim();
              final durationMinutes =
                  hours.isEmpty ? null : (double.parse(hours) * 60).round();
              await ApiProviderService.createProviderService(
                token: token,
                serviceId: selectedId!,
                price: double.parse(priceCtrl.text.trim()),
                estimatedDurationMinutes: durationMinutes,
              );
              if (mounted) {
                Navigator.pop(ctx);
                ref.read(providerServicesProvider.notifier).fetchServices();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteService(int serviceId) async {
    final token = ref.read(userProvider).token ?? '';
    final result = await ApiProviderService.deleteProviderService(
      token: token,
      serviceId: serviceId,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      ref.read(providerServicesProvider.notifier).fetchServices();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Unable to delete service.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Services', style: AppTextStyles.heading3),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filled(
              onPressed: _showAddService,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final servicesState = ref.watch(providerServicesProvider);

    if (servicesState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (servicesState.errorMessage != null) {
      return _StateMessage(
        icon: Icons.error_outline_rounded,
        text: servicesState.errorMessage!,
      );
    }
    if (servicesState.services.isEmpty) {
      return const _StateMessage(
        icon: Icons.widgets_rounded,
        text: 'No services added yet.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(providerServicesProvider.notifier).fetchServices(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        itemCount: servicesState.services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final service = servicesState.services[index] as Map<String, dynamic>;
          final name = service['service_name']?.toString() ?? 'Service';
          final price = service['price'];
          final priceText = price is num ? 'Rs ${price.toStringAsFixed(0)}' : 'Rs -';
          final duration = service['estimated_duration_minutes'];
          final durationText =
              duration is num ? '${(duration / 60).toStringAsFixed(1)} hrs' : 'Flexible timing';
          final serviceId = service['service_id'] as int?;

          return _ServiceTile(
            name: name,
            subtitle: '$durationText service',
            price: priceText,
            onDelete: serviceId == null ? null : () => _deleteService(serviceId),
          );
        },
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final String price;
  final VoidCallback? onDelete;

  const _ServiceTile({
    required this.name,
    required this.subtitle,
    required this.price,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.plumbing_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.hint),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Active',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
          ),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textLight, size: 58),
            const SizedBox(height: 12),
            Text(text, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
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
