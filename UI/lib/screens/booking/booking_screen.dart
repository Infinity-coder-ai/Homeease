import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/booking_form.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> provider;
  final int serviceId;
  final String serviceName;

  const BookingScreen({
    super.key,
    required this.provider,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateCtrl = TextEditingController();
  final _startTimeCtrl = TextEditingController();
  final _endTimeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _cityCtrl.text = widget.provider['city'] ?? '';
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _pincodeCtrl.dispose();
    _landmarkCtrl.dispose();
    super.dispose();
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _formatTime(TimeOfDay time) {
    return '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}';
  }

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _dateCtrl.text = _formatDate(picked);
    });
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      _startTime = picked;
      _startTimeCtrl.text = _formatTime(picked);
    });
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      _endTime = picked;
      _endTimeCtrl.text = _formatTime(picked);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time.')),
      );
      return;
    }

    if (_toMinutes(_endTime!) <= _toMinutes(_startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }

    final token = ref.read(userProvider).token ?? '';
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to continue.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await ApiBookingService.createBooking(
      token: token,
      providerId: widget.provider['id'] as int,
      serviceId: widget.serviceId,
      bookingDate: _formatDate(_selectedDate!),
      startTime: _formatTime(_startTime!),
      endTime: _formatTime(_endTime!),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      landmark: _landmarkCtrl.text.trim().isEmpty
          ? null
          : _landmarkCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking created successfully.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Booking failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.provider['name'] ?? 'Unknown';
    final area = widget.provider['area'] ?? '';
    final city = widget.provider['city'] ?? '';
    final price = widget.provider['price'];
    final priceText = price is num
        ? 'Rs ${price.toStringAsFixed(0)}'
        : 'Auto';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Book Provider', style: AppTextStyles.heading3),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              Container(
                decoration: AppDecorations.card,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text(widget.serviceName, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.textMedium,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '$area, $city',
                            style: AppTextStyles.hint,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        const Text('Price', style: AppTextStyles.label),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            priceText,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              BookingForm(
                formKey: _formKey,
                dateController: _dateCtrl,
                startTimeController: _startTimeCtrl,
                endTimeController: _endTimeCtrl,
                addressController: _addressCtrl,
                cityController: _cityCtrl,
                pincodeController: _pincodeCtrl,
                landmarkController: _landmarkCtrl,
                onPickDate: _pickDate,
                onPickStartTime: _pickStartTime,
                onPickEndTime: _pickEndTime,
                onSubmit: _submit,
                isSubmitting: _isSubmitting,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
