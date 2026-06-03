// Renders the correct form for each wizard step (profile, service, slots, docs).
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../models/availability_slot.dart';
import 'empty_step_card.dart';
import 'provider_availability_step.dart';
import 'provider_documents_step.dart';
import 'provider_profile_step.dart';
import 'provider_service_step.dart';

class BecomeProviderStepBody extends StatelessWidget {
  final int stepIndex;
  final GlobalKey<FormState> profileFormKey;
  final GlobalKey<FormState> serviceFormKey;
  final TextEditingController experienceCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController areaCtrl;
  final TextEditingController pincodeCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController durationCtrl;
  final Future<List<dynamic>>? servicesFuture;
  final int? selectedServiceId;
  final ValueChanged<int?> onSelectService;
  final List<AvailabilitySlot> slots;
  final VoidCallback onAddSlot;
  final void Function(int index) onRemoveSlot;
  final bool documentsChecked;
  final bool documentsReady;
  final String? profilePhotoName;
  final String? idProofName;
  final VoidCallback onPickProfile;
  final VoidCallback onPickIdProof;

  const BecomeProviderStepBody({
    super.key,
    required this.stepIndex,
    required this.profileFormKey,
    required this.serviceFormKey,
    required this.experienceCtrl,
    required this.cityCtrl,
    required this.areaCtrl,
    required this.pincodeCtrl,
    required this.priceCtrl,
    required this.durationCtrl,
    required this.servicesFuture,
    required this.selectedServiceId,
    required this.onSelectService,
    required this.slots,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.documentsChecked,
    required this.documentsReady,
    required this.profilePhotoName,
    required this.idProofName,
    required this.onPickProfile,
    required this.onPickIdProof,
  });

  @override
  Widget build(BuildContext context) {
    switch (stepIndex) {
      case 0:
        return Form(
          key: profileFormKey,
          child: ProviderProfileStep(
            experienceController: experienceCtrl,
            cityController: cityCtrl,
            areaController: areaCtrl,
            pincodeController: pincodeCtrl,
          ),
        );
      case 1:
        return FutureBuilder<List<dynamic>>(
          future: servicesFuture,
          builder: (context, snapshot) {
            final services = snapshot.data ?? [];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            if (services.isEmpty) {
              return const EmptyStepCard(
                title: 'No services available.',
                subtitle: 'Please try again later.',
              );
            }
            return Form(
              key: serviceFormKey,
              child: ProviderServiceStep(
                services: services,
                selectedServiceId: selectedServiceId,
                onSelectService: onSelectService,
                priceController: priceCtrl,
                durationController: durationCtrl,
              ),
            );
          },
        );
      case 2:
        return ProviderAvailabilityStep(
          slots: slots,
          onAddSlot: onAddSlot,
          onRemoveSlot: onRemoveSlot,
        );
      default:
        return (documentsChecked && documentsReady)
            ? const EmptyStepCard(
                title: 'Documents already on file.',
                subtitle: 'No additional documents are required.',
              )
            : ProviderDocumentsStep(
                profilePhotoName: profilePhotoName,
                idProofName: idProofName,
                onPickProfile: onPickProfile,
                onPickIdProof: onPickIdProof,
              );
    }
  }
}
