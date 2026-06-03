import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class BookingForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController dateController;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController pincodeController;
  final TextEditingController landmarkController;
  final VoidCallback onPickDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const BookingForm({
    super.key,
    required this.formKey,
    required this.dateController,
    required this.startTimeController,
    required this.endTimeController,
    required this.addressController,
    required this.cityController,
    required this.pincodeController,
    required this.landmarkController,
    required this.onPickDate,
    required this.onPickStartTime,
    required this.onPickEndTime,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Booking Details', style: AppTextStyles.heading2),
          const SizedBox(height: AppSpacing.md),
          _label('Date'),
          TextFormField(
            controller: dateController,
            readOnly: true,
            onTap: onPickDate,
            decoration: _fieldDecoration(
              hintText: 'Select date',
              prefixIcon: Icons.calendar_month_rounded,
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Date required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Start Time'),
                    TextFormField(
                      controller: startTimeController,
                      readOnly: true,
                      onTap: onPickStartTime,
                      decoration: _fieldDecoration(
                        hintText: 'Start',
                        prefixIcon: Icons.schedule_rounded,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Start time required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('End Time'),
                    TextFormField(
                      controller: endTimeController,
                      readOnly: true,
                      onTap: onPickEndTime,
                      decoration: _fieldDecoration(
                        hintText: 'End',
                        prefixIcon: Icons.schedule_rounded,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'End time required' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _label('Address'),
          TextFormField(
            controller: addressController,
            decoration: _fieldDecoration(
              hintText: 'House no, street, etc.',
              prefixIcon: Icons.home_outlined,
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Address required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          _label('City'),
          TextFormField(
            controller: cityController,
            decoration: _fieldDecoration(
              hintText: 'City',
              prefixIcon: Icons.location_city_outlined,
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'City required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          _label('Pincode'),
          TextFormField(
            controller: pincodeController,
            keyboardType: TextInputType.number,
            decoration: _fieldDecoration(
              hintText: 'Pincode',
              prefixIcon: Icons.markunread_mailbox_outlined,
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Pincode required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          _label('Landmark (Optional)'),
          TextFormField(
            controller: landmarkController,
            decoration: _fieldDecoration(
              hintText: 'Nearby location',
              prefixIcon: Icons.place_outlined,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Confirm Booking'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text, style: AppTextStyles.label),
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: AppColors.textMedium, size: 20),
    );
  }
}
