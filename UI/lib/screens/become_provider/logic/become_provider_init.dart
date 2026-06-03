// Loads catalog services and existing document status for the wizard.
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';
import '../models/availability_slot.dart';
import '../widgets/days_picker_dialog.dart';

class BecomeProviderInit {
  BecomeProviderInit._();

  static Future<List<dynamic>> loadServices() async {
    final result = await ApiCatalogService.getServiceCatalog();
    if (result['success'] == true) {
      return result['data'] as List<dynamic>;
    }
    return [];
  }

  static Future<({bool checked, bool ready})> loadDocumentsStatus(
    String? token,
  ) async {
    if (token == null) {
      return (checked: true, ready: false);
    }
    final result = await ApiProviderService.getProviderDocuments(token: token);
    if (result['success'] == true) {
      final docs = result['data'] as List<dynamic>;
      final hasProfile = docs.any((doc) {
        final map = doc as Map<String, dynamic>;
        return map['document_type']?.toString() == 'PROFILE_PHOTO';
      });
      final hasId = docs.any((doc) {
        final map = doc as Map<String, dynamic>;
        return map['document_type']?.toString() == 'AADHAAR';
      });
      return (checked: true, ready: hasProfile && hasId);
    }
    return (checked: true, ready: false);
  }

  static Future<void> addAvailabilitySlot({
    required BuildContext context,
    required List<AvailabilitySlot> slots,
    required VoidCallback onSlotsChanged,
  }) async {
    final days = await showDialog<List<int>>(
      context: context,
      builder: (ctx) => const DaysPickerDialog(),
    );
    if (days == null || days.isEmpty) return;
    if (!context.mounted) return;

    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (start == null) return;
    if (!context.mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (end == null) return;

    for (final day in days) {
      slots.add(
        AvailabilitySlot(dayOfWeek: day, startTime: start, endTime: end),
      );
    }
    onSlotsChanged();
  }

  static Future<XFile?> pickGalleryImage(ImagePicker picker) {
    return picker.pickImage(source: ImageSource.gallery);
  }
}
