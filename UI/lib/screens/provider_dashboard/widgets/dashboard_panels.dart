import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// White card container used across provider dashboard widgets.
class DashboardWhitePanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const DashboardWhitePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEEF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class DashboardPanelLoading extends StatelessWidget {
  const DashboardPanelLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardWhitePanel(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }
}

class DashboardEmptyPanel extends StatelessWidget {
  final IconData icon;
  final String text;

  const DashboardEmptyPanel({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return DashboardWhitePanel(
      child: Row(
        children: [
          Icon(icon, color: AppColors.textLight),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
