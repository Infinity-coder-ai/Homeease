import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AuthBackdrop extends StatelessWidget {
  final Widget child;

  const AuthBackdrop({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F6F2),
      child: Stack(
        children: [
          const _BackdropBlob(
            alignment: Alignment(-0.85, -0.75),
            size: 200,
            opacity: 0.12,
          ),
          const _BackdropBlob(
            alignment: Alignment(0.9, -0.4),
            size: 120,
            opacity: 0.10,
          ),
          const _BackdropBlob(
            alignment: Alignment(0.9, 0.9),
            size: 240,
            opacity: 0.12,
          ),
          child,
        ],
      ),
    );
  }
}

class _BackdropBlob extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final double opacity;

  const _BackdropBlob({
    required this.alignment,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryLight.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
