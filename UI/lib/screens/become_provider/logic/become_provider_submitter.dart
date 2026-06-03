import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';
import '../models/availability_slot.dart';

/// API calls for each step of the become-provider wizard.
class BecomeProviderSubmitter {
  BecomeProviderSubmitter._();

  static String formatTime(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static Future<bool> submitProfile({
    required String token,
    required int experienceYears,
    required String city,
    required String area,
    required String pincode,
    required void Function(String message) onError,
  }) async {
    final result = await ApiProviderService.createProviderProfile(
      token: token,
      experienceYears: experienceYears,
      city: city,
      area: area,
      pincode: pincode,
    );

    if (result['success'] == true) return true;

    final message = result['message']?.toString() ?? 'Unable to save profile.';
    final normalized = message.toLowerCase();
    if (normalized.contains('already registered') ||
        normalized.contains('already registed') ||
        normalized.contains('already regisetered') ||
        normalized.contains('regisetered') ||
        normalized.contains('already exists')) {
      return true;
    }

    onError(message);
    return false;
  }

  static Future<bool> submitService({
    required String token,
    required int serviceId,
    required double price,
    required int? durationMinutes,
    required void Function(String message) onError,
  }) async {
    final result = await ApiProviderService.createProviderService(
      token: token,
      serviceId: serviceId,
      price: price,
      estimatedDurationMinutes: durationMinutes,
    );

    if (result['success'] == true) return true;
    onError(result['message']?.toString() ?? 'Unable to add service.');
    return false;
  }

  static Future<bool> submitAvailability({
    required String token,
    required List<AvailabilitySlot> slots,
    required void Function(String message) onError,
  }) async {
    final payload = slots
        .map((slot) => {
              'day_of_week': slot.dayOfWeek,
              'start_time': formatTime(slot.startTime),
              'end_time': formatTime(slot.endTime),
            })
        .toList();

    final result = await ApiProviderService.createProviderAvailability(
      token: token,
      slots: payload,
    );

    if (result['success'] == true) return true;
    onError(result['message']?.toString() ?? 'Unable to save availability.');
    return false;
  }

  static Future<bool> submitDocuments({
    required String token,
    required XFile profilePhoto,
    required XFile idProof,
    required void Function(String message) onError,
  }) async {
    final profileResult = await ApiProviderService.uploadProviderDocument(
      token: token,
      documentType: 'PROFILE_PHOTO',
      filePath: profilePhoto.path,
    );
    if (profileResult['success'] != true) {
      onError(profileResult['message']?.toString() ?? 'Profile upload failed.');
      return false;
    }

    final idResult = await ApiProviderService.uploadProviderDocument(
      token: token,
      documentType: 'AADHAAR',
      filePath: idProof.path,
    );
    if (idResult['success'] != true) {
      onError(idResult['message']?.toString() ?? 'ID upload failed.');
      return false;
    }

    return true;
  }
}
