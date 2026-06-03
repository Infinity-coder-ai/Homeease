import 'dart:ui';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// COLORS — single source of truth for the entire app
// Every screen imports ONLY this file for colors, text, spacing
// ─────────────────────────────────────────────────────────────────
class AppColors {
  // Primary palette (approximate from the reference UI image)
  static const Color primary = Color(0xFF6F6CEB); // soft purple CTA
  static const Color primaryLight = Color(0xFFE8E6F7); // lavender tint
  static const Color primaryDark = Color(0xFF514ED3); // deeper purple

  // Secondary & Tertiary
  static const Color secondary = Color(0xFFBFE7D3); // mint
  static const Color tertiary = Color(0xFFF6C6D8); // blush pink

  // Backgrounds
  static const Color background = Color(0xFFF4F1E9); // warm paper
  static const Color surface = Color(0xFFFFFFFF); // clean white cards

  // Text
  static const Color textDark = Color(0xFF1F1F1F);
  static const Color textMedium = Color(0xFF3E3E3E);
  static const Color textLight = Color(0xFF6B6B6B);

  // Input fields
  static const Color inputFill = Color(0xFFF3F1EA);
  static const Color inputBorder = Color(0xFFE0DDD6);

  // Card accent tints
  static const Color accentGreen = Color(0xFFBFE7D3);
  static const Color accentPeach = Color(0xFFFAD8C7);
  static const Color accentLavender = Color(0xFFD8D0F2);
  static const Color accentBlue = Color(0xFFCFE4F8);
  static const Color accentAmber = Color(0xFFF7E4B5);
  static const Color accentCoral = Color(0xFFF1C2B4);

  // Status colors
  static const Color success = Color(0xFF56B38C);
  static const Color error = Color(0xFFE06A6A);
  static const Color warning = Color(0xFFE9B874);

  // Misc
  static const Color gold = Color(0xFFE9B874);
}

// ─────────────────────────────────────────────────────────────────
// TEXT STYLES — reuse these across every screen for consistency
// ─────────────────────────────────────────────────────────────────
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textMedium,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle hint = TextStyle(
    fontSize: 14,
    color: AppColors.textLight,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryDark,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
}

// ─────────────────────────────────────────────────────────────────
// SPACING — consistent gaps across the app
// ─────────────────────────────────────────────────────────────────
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 24);
}

// ─────────────────────────────────────────────────────────────────
// DECORATIONS — reusable box decorations
// ─────────────────────────────────────────────────────────────────
class AppDecorations {
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryLight,
          width: 1,
        ),
        boxShadow: [
         BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 16,
        offset: const Offset(0, 4),
        )
        ],
      );

  static BoxDecoration pillBadge(Color backgroundColor) => BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      );

  // ── Glassmorphism card ────────────────────────────────────────
  // Translucent card with blur. Wrap content with GlassCard widget below.
  static BoxDecoration glassCard(Color tintColor) => BoxDecoration(
        color: tintColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: tintColor.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────
// GLASS CARD WIDGET — reusable frosted-glass container
// Wraps child in a ClipRRect + BackdropFilter for the blur effect
// ─────────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Color tintColor;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.tintColor,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: AppDecorations.glassCard(tintColor),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────
// THEME — plug this into MaterialApp once in main.dart
// All screens automatically inherit these styles
// ─────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),

        // ── Text ────────────────────────────────────────────────
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.heading1,
          titleLarge: AppTextStyles.heading2,
          titleMedium: AppTextStyles.heading3,
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.textDark,
          ),
          bodyMedium: AppTextStyles.bodyMedium,
          labelLarge: AppTextStyles.buttonText,
        ),

        // ── Input Fields ─────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.error, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          hintStyle: AppTextStyles.hint,
          errorStyle: const TextStyle(
            color: AppColors.error,
            fontSize: 12,
          ),
        ),

        // ── Primary Button (coral-red, full-width, rounded) ────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textDark,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
            textStyle: AppTextStyles.buttonText,
          ),
        ),

        // ── AppBar ───────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.textDark),
          titleTextStyle: AppTextStyles.heading3,
        ),
      );
}
