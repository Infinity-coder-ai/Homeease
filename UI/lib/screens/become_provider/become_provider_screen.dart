// Multi-step wizard: profile → service → availability → documents.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../provider_dashboard/provider_application_status_screen.dart';
import 'logic/become_provider_flow.dart';
import 'models/availability_slot.dart';
import 'widgets/become_provider_step_body.dart';
import 'widgets/become_provider_step_controls.dart';
import 'widgets/become_provider_step_page.dart';
import 'logic/become_provider_init.dart';

class BecomeProviderScreen extends ConsumerStatefulWidget {
  const BecomeProviderScreen({super.key});

  @override
  ConsumerState<BecomeProviderScreen> createState() =>
      _BecomeProviderScreenState();
}

class _BecomeProviderScreenState extends ConsumerState<BecomeProviderScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _serviceFormKey = GlobalKey<FormState>();
  final _experienceCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final List<AvailabilitySlot> _slots = [];
  final _picker = ImagePicker();
  Future<List<dynamic>>? _servicesFuture;
  int _currentStep = 0;
  int? _selectedServiceId;
  bool _isBusy = false;
  bool _documentsChecked = false;
  bool _documentsReady = false;
  XFile? _profilePhoto;
  XFile? _idProof;

  @override
  void dispose() {
    _experienceCtrl.dispose();
    _cityCtrl.dispose();
    _areaCtrl.dispose();
    _pincodeCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _servicesFuture = BecomeProviderInit.loadServices();
    _loadDocumentsStatus();
  }

  Future<void> _loadDocumentsStatus() async {
    final status =
        await BecomeProviderInit.loadDocumentsStatus(_tokenOrNull());
    if (!mounted) return;
    setState(() {
      _documentsChecked = status.checked;
      _documentsReady = status.ready;
    });
  }

  Future<void> _addSlot() async {
    await BecomeProviderInit.addAvailabilitySlot(
      context: context,
      slots: _slots,
      onSlotsChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  Future<void> _pickProfilePhoto() async {
    final file = await BecomeProviderInit.pickGalleryImage(_picker);
    if (file == null) return;
    setState(() => _profilePhoto = file);
  }

  Future<void> _pickIdProof() async {
    final file = await BecomeProviderInit.pickGalleryImage(_picker);
    if (file == null) return;
    setState(() => _idProof = file);
  }

  String? _tokenOrNull() {
    final token = ref.read(userProvider).token ?? '';
    if (token.isEmpty) return null;
    return token;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _continue() async {
    setState(() => _isBusy = true);
    if (!BecomeProviderFlow.validateCurrentStep(
      currentStep: _currentStep,
      profileFormKey: _profileFormKey,
      serviceFormKey: _serviceFormKey,
      selectedServiceId: _selectedServiceId,
      slots: _slots,
      documentsChecked: _documentsChecked,
      documentsReady: _documentsReady,
      profilePhoto: _profilePhoto,
      idProof: _idProof,
      showMessage: _showMessage,
    )) {
      setState(() => _isBusy = false);
      return;
    }

    final ok = await BecomeProviderFlow.submitStep(
      currentStep: _currentStep,
      token: _tokenOrNull(),
      showMessage: _showMessage,
      profileFormKey: _profileFormKey,
      serviceFormKey: _serviceFormKey,
      experienceCtrl: _experienceCtrl,
      cityCtrl: _cityCtrl,
      areaCtrl: _areaCtrl,
      pincodeCtrl: _pincodeCtrl,
      selectedServiceId: _selectedServiceId,
      priceCtrl: _priceCtrl,
      durationCtrl: _durationCtrl,
      slots: _slots,
      profilePhoto: _profilePhoto,
      idProof: _idProof,
      documentsChecked: _documentsChecked,
      documentsReady: _documentsReady,
    );

    if (ok && _currentStep == 3) {
      setState(() {
        _documentsChecked = true;
        _documentsReady = true;
      });
    }

    setState(() => _isBusy = false);
    if (!ok) return;

    if (_currentStep < 3) {
      setState(() => _currentStep += 1);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Provider profile completed.')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ProviderApplicationStatusScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Become a Provider', style: AppTextStyles.heading3),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: BecomeProviderStepPage(
                  key: ValueKey<int>(_currentStep),
                  stepIndex: _currentStep,
                  stepBody: BecomeProviderStepBody(
                    stepIndex: _currentStep,
                    profileFormKey: _profileFormKey,
                    serviceFormKey: _serviceFormKey,
                    experienceCtrl: _experienceCtrl,
                    cityCtrl: _cityCtrl,
                    areaCtrl: _areaCtrl,
                    pincodeCtrl: _pincodeCtrl,
                    priceCtrl: _priceCtrl,
                    durationCtrl: _durationCtrl,
                    servicesFuture: _servicesFuture,
                    selectedServiceId: _selectedServiceId,
                    onSelectService: (value) =>
                        setState(() => _selectedServiceId = value),
                    slots: _slots,
                    onAddSlot: _addSlot,
                    onRemoveSlot: (index) => setState(() => _slots.removeAt(index)),
                    documentsChecked: _documentsChecked,
                    documentsReady: _documentsReady,
                    profilePhotoName: _profilePhoto?.name,
                    idProofName: _idProof?.name,
                    onPickProfile: _pickProfilePhoto,
                    onPickIdProof: _pickIdProof,
                  ),
                ),
              ),
            ),
            BecomeProviderStepControls(
              currentStep: _currentStep,
              isBusy: _isBusy,
              onBack: () => setState(() => _currentStep -= 1),
              onContinue: _continue,
            ),
          ],
        ),
      ),
    );
  }
}
