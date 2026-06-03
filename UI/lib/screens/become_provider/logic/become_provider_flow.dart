// Validation rules for each step of the become-provider wizard.
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/availability_slot.dart';
import 'become_provider_submitter.dart';

typedef ShowMessage = void Function(String message);

class BecomeProviderFlow {
  BecomeProviderFlow._();

  static bool validateCurrentStep({
    required int currentStep,
    required GlobalKey<FormState> profileFormKey,
    required GlobalKey<FormState> serviceFormKey,
    required int? selectedServiceId,
    required List<AvailabilitySlot> slots,
    required bool documentsChecked,
    required bool documentsReady,
    required XFile? profilePhoto,
    required XFile? idProof,
    required ShowMessage showMessage,
  }) {
    switch (currentStep) {
      case 0:
        return profileFormKey.currentState?.validate() ?? false;
      case 1:
        if (!(serviceFormKey.currentState?.validate() ?? false)) return false;
        if (selectedServiceId == null) {
          showMessage('Select a service before continuing.');
          return false;
        }
        return true;
      case 2:
        if (slots.isEmpty) {
          showMessage('Add at least one slot to continue.');
          return false;
        }
        return true;
      default:
        if (documentsChecked && documentsReady) return true;
        if (profilePhoto == null || idProof == null) {
          showMessage('Please upload both documents to finish.');
          return false;
        }
        return true;
    }
  }

  static Future<bool> submitStep({
    required int currentStep,
    required String? token,
    required ShowMessage showMessage,
    required GlobalKey<FormState> profileFormKey,
    required GlobalKey<FormState> serviceFormKey,
    required TextEditingController experienceCtrl,
    required TextEditingController cityCtrl,
    required TextEditingController areaCtrl,
    required TextEditingController pincodeCtrl,
    required int? selectedServiceId,
    required TextEditingController priceCtrl,
    required TextEditingController durationCtrl,
    required List<AvailabilitySlot> slots,
    required XFile? profilePhoto,
    required XFile? idProof,
    required bool documentsChecked,
    required bool documentsReady,
  }) async {
    if (token == null) {
      showMessage('Please login to continue.');
      return false;
    }

    switch (currentStep) {
      case 0:
        if (!(profileFormKey.currentState?.validate() ?? false)) {
          return false;
        }
        final experienceYears = int.tryParse(experienceCtrl.text.trim());
        if (experienceYears == null) {
          showMessage('Enter a valid experience value.');
          return false;
        }
        return BecomeProviderSubmitter.submitProfile(
          token: token,
          experienceYears: experienceYears,
          city: cityCtrl.text.trim(),
          area: areaCtrl.text.trim(),
          pincode: pincodeCtrl.text.trim(),
          onError: showMessage,
        );
      case 1:
        if (!(serviceFormKey.currentState?.validate() ?? false)) {
          return false;
        }
        if (selectedServiceId == null) {
          showMessage('Select a service before continuing.');
          return false;
        }
        final price = double.tryParse(priceCtrl.text.trim());
        if (price == null) {
          showMessage('Enter a valid service price.');
          return false;
        }
        final durationText = durationCtrl.text.trim();
        final durationMinutes = durationText.isEmpty
            ? null
            : (double.tryParse(durationText) ?? -1) > 0
                ? (double.parse(durationText) * 60).round()
                : null;
        if (durationText.isNotEmpty && durationMinutes == null) {
          showMessage('Enter a valid duration in hours.');
          return false;
        }
        return BecomeProviderSubmitter.submitService(
          token: token,
          serviceId: selectedServiceId,
          price: price,
          durationMinutes: durationMinutes,
          onError: showMessage,
        );
      case 2:
        if (slots.isEmpty) {
          showMessage('Add at least one slot to continue.');
          return false;
        }
        return BecomeProviderSubmitter.submitAvailability(
          token: token,
          slots: slots,
          onError: showMessage,
        );
      default:
        if (documentsChecked && documentsReady) return true;
        if (profilePhoto == null || idProof == null) {
          showMessage('Please upload both documents to finish.');
          return false;
        }
        return BecomeProviderSubmitter.submitDocuments(
          token: token,
          profilePhoto: profilePhoto,
          idProof: idProof,
          onError: showMessage,
        );
    }
  }
}
