import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'provider_step_header.dart';

class ProviderProfileStep extends StatelessWidget {
  final TextEditingController experienceController;
  final TextEditingController cityController;
  final TextEditingController areaController;
  final TextEditingController pincodeController;

  const ProviderProfileStep({
    super.key,
    required this.experienceController,
    required this.cityController,
    required this.areaController,
    required this.pincodeController,
  });

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
            title: 'Personal Information',
            subtitle: 'Please provide your personal details.',
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: experienceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Experience (years)',
              prefixIcon: Icon(Icons.workspace_premium_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Experience is required';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: cityController,
            decoration: const InputDecoration(
              labelText: 'City',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'City is required';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: areaController,
            decoration: const InputDecoration(
              labelText: 'Area',
              prefixIcon: Icon(Icons.map_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Area is required';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: pincodeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Pincode',
              prefixIcon: Icon(Icons.local_post_office_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Pincode is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
