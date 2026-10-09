import 'package:flutter/material.dart';

/// Design token palette for سوزوكي app.
/// Primary: Deep Blue  — authority, trust
/// Accent:  Amber      — energy, action
/// Surface: Light Gray — clean, minimal
abstract final class AppColors {
  // ── Primary ───────────────────────────────────────────────────────────────
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF0D47A1);

  // Primary Palette
  static const Color primary = Color(0xFF00288E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1E40AF);
  static const Color onPrimaryContainer = Color(0xFFA8B8FF);
  static const Color primaryFixed = Color(0xFFDDE1FF);
  
  // Secondary & Tertiary
  static const Color secondary = Color(0xFF855300);
  static const Color secondaryContainer = Color(0xFFFEA619);
  static const Color onSecondaryContainer = Color(0xFF684000);
  static const Color tertiary = Color(0xFF003C36);
  static const Color tertiaryContainer = Color(0xFF00554E);

  // Surface & Background
  static const Color surface = Color(0xFFFAF8FF);
  static const Color onSurface = Color(0xFF131B2E);
  static const Color onSurfaceVariant = Color(0xFF444653);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F3FF);
  static const Color surfaceContainer = Color(0xFFEAEDFF);
  static const Color surfaceContainerHigh = Color(0xFFE2E7FF);
  static const Color surfaceContainerHighest = Color(0xFFDAE2FD);

  // Outlines & Errors
  static const Color outline = Color(0xFF757684);
  static const Color outlineVariant = Color(0xFFC4C5D5);
  static const Color error = Color(0xFFBA1A1A);

  // ── Accent / Amber ────────────────────────────────────────────────────────
  static const Color amber = Color(0xFFFFC107);
  static const Color amberDark = Color(0xFFFF8F00);
  static const Color onAmber = Color(0xFF1A1A1A);

  // ── Surface & Background ──────────────────────────────────────────────────
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color background = Color(0xFFF0F4F8);
  static const Color onBackground = Color(0xFF1A1A2E);

  // ── Grey Scale ────────────────────────────────────────────────────────────
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color.fromARGB(255, 223, 221, 221);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF0288D1);

  // ── Driver / Passenger Role Colors ────────────────────────────────────────
  static const Color driverBadge = Color(0xFF1B5E20);
  static const Color passengerBadge = Color(0xFF1565C0);

  // ── Card & Divider ────────────────────────────────────────────────────────
  static const Color cardShadow = Color(0x1A000000);
  static const Color divider = Color(0xFFE0E0E0);

  // ── Map UI ────────────────────────────────────────────────────────────────
  static const Color mapAccent = Color(0xFF1565C0);
  static const Color markerSuzuki = Color(0xFFFFC107);

  // ── Stitch Design Tokens ──────────────────────────────────────────────────
  static const Color stitchCobalt = Color(0xFF1E40AF);
  static const Color stitchCobaltLight = Color(0xFFEFF6FF);
  static const Color stitchAmber = Color(0xFFF59E0B);
  static const Color stitchAmberLight = Color(0xFFFEF3C7);
  static const Color stitchTeal = Color(0xFF0D9488);
  static const Color stitchTealLight = Color(0xFFCCFBF1);

  // ── Egyptian Vehicle Plate Colors ──────────────────────────────────────────
  static const Color plateHeaderBlue = Color(0xFF0284C7);
  static const Color plateHeaderBg = Color(0xFFE0F2FE);
  static const Color plateBorder = Color(0xFF94A3B8);
  static const Color plateBackground = Color(0xFFF8FAFC);
}
