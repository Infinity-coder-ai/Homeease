import 'package:flutter/material.dart';

/// Responsive spacing and typography for the customer home tab.
///
/// Scales UI from a 390pt-wide design reference so layouts look consistent
/// on small and large phones.
class HomeResponsive {
  final double scale;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final double avatarSize;
  final double headerIconSize;
  final double headlineSize;
  final double spacingSm;
  final double spacingMd;
  final double promoImageSize;
  final double promoButtonHeight;

  const HomeResponsive._({
    required this.scale,
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.avatarSize,
    required this.headerIconSize,
    required this.headlineSize,
    required this.spacingSm,
    required this.spacingMd,
    required this.promoImageSize,
    required this.promoButtonHeight,
  });

  factory HomeResponsive.of(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 390).clamp(0.85, 1.15);

    return HomeResponsive._(
      scale: scale,
      horizontalPadding: 18 * scale,
      topPadding: 16 * scale,
      bottomPadding: 28 * scale,
      avatarSize: 42 * scale,
      headerIconSize: 40 * scale,
      headlineSize: 32 * scale,
      spacingSm: 10 * scale,
      spacingMd: 14 * scale,
      promoImageSize: 200 * scale,
      promoButtonHeight: 40 * scale,
    );
  }

  EdgeInsets get pagePadding =>
      EdgeInsets.fromLTRB(horizontalPadding, topPadding, horizontalPadding, bottomPadding);
}
