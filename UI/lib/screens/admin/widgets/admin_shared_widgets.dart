// Reusable admin UI: status chips, step flow, section headers.
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AdminStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const AdminStatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AdminSectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailingWidget;

  const AdminSectionHeader({
    super.key,
    required this.icon,
    required this.label,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
        if (trailingWidget != null) trailingWidget!,
      ],
    );
  }
}

class AdminStepFlowIndicator extends StatelessWidget {
  final bool step1Done;
  final bool step2Done;
  final bool step3Done;

  const AdminStepFlowIndicator({
    super.key,
    required this.step1Done,
    required this.step2Done,
    required this.step3Done,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AdminStepDot(done: step1Done, label: 'Docs'),
        AdminStepLine(done: step1Done && step2Done),
        AdminStepDot(done: step2Done, label: 'BG Verify'),
        AdminStepLine(done: step2Done && step3Done),
        AdminStepDot(done: step3Done, label: 'Role'),
      ],
    );
  }
}

class AdminStepDot extends StatelessWidget {
  final bool done;
  final String label;

  const AdminStepDot({super.key, required this.done, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: done ? AppColors.success : const Color(0xFFDDE1EC),
            shape: BoxShape.circle,
            border: Border.all(
              color: done ? AppColors.success : const Color(0xFFB5BBC8),
              width: 2,
            ),
          ),
          child: Icon(
            done ? Icons.check_rounded : Icons.circle,
            color: done ? Colors.white : const Color(0xFFB5BBC8),
            size: done ? 14 : 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: done ? AppColors.success : AppColors.textLight,
          ),
        ),
      ],
    );
  }
}

class AdminStepLine extends StatelessWidget {
  final bool done;

  const AdminStepLine({super.key, required this.done});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: done ? AppColors.success : const Color(0xFFDDE1EC),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}
