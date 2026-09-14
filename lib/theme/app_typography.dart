import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTypography defines the Inter-based typography system matching DESIGN.md.
class AppTypography {
  AppTypography._();

  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 64 / 57,
    letterSpacing: -1.14,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 40 / 32,
    letterSpacing: -0.32,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMobile = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
    color: AppColors.onSurface,
  );

  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 28 / 22,
    color: AppColors.onSurface,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.6,
    color: AppColors.onSurfaceVariant,
  );

  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMobile,
        titleLarge: titleLarge,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        labelMedium: labelMedium,
      );
}
