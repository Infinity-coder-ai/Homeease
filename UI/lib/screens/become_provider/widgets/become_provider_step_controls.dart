// Back / Next / Finish buttons pinned below the wizard.
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class BecomeProviderStepControls extends StatelessWidget {
  final int currentStep;
  final bool isBusy;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const BecomeProviderStepControls({
    super.key,
    required this.currentStep,
    required this.isBusy,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep == 3;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: const BoxDecoration(color: AppColors.background),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: isBusy ? null : onBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.18),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: isBusy ? null : onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(isLast ? 'Finish' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}
