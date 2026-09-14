import 'package:flutter/material.dart';

/// AppColors defines the exact palette tokens for LifeOS:
/// - Background: Near-Black (#0B0D10)
/// - Cards / Surfaces: Dark Charcoal (#171A20)
/// - Primary: Electric Purple (#8B5CF6)
/// - Secondary / Accent: Cyan (#22D3EE)
/// - Primary Text: White (#FFFFFF)
/// - Secondary Text: Muted Gray (#A1A1AA)
class AppColors {
  AppColors._();

  // Primary: Electric Purple
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryContainer = Color(0xFF8B5CF6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
  static const Color inversePrimary = Color(0xFFA78BFA);

  // Secondary / Accent: Cyan
  static const Color secondary = Color(0xFF22D3EE);
  static const Color secondaryContainer = Color(0xFF0E7490);
  static const Color onSecondary = Color(0xFF0B0D10);
  static const Color onSecondaryContainer = Color(0xFFCFFAFE);

  // Tertiary: Subtle Blue / Cyan Tint
  static const Color tertiary = Color(0xFF38BDF8);
  static const Color tertiaryContainer = Color(0xFF0369A1);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFE0F2FE);

  // Surfaces & Background (Near-Black & Dark Charcoal)
  static const Color background = Color(0xFF0B0D10);
  static const Color onBackground = Color(0xFFFFFFFF);

  static const Color surface = Color(0xFF171A20);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFA1A1AA);

  static const Color surfaceContainerLowest = Color(0xFF0B0D10);
  static const Color surfaceContainerLow = Color(0xFF121418);
  static const Color surfaceContainer = Color(0xFF171A20);
  static const Color surfaceContainerHigh = Color(0xFF1E222A);
  static const Color surfaceContainerHighest = Color(0xFF262B35);
  static const Color surfaceBright = Color(0xFF2E3440);

  // Outlines & Borders
  static const Color outline = Color(0xFF52525B);
  static const Color outlineVariant = Color(0xFF27272A);
  static const Color surfaceTint = Color(0xFF8B5CF6);

  // Errors & Alerts
  static const Color error = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFF7F1D1D);
  static const Color onErrorContainer = Color(0xFFFEE2E2);

  // Glassmorphic Overlays & Glows
  static const Color glassBackground = Color(0xCC171A20);
  static const Color glassBorder = Color(0x26A1A1AA);
  static const Color aiGlowPulse = Color(0x338B5CF6);
}
