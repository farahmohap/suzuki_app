import 'package:flutter/material.dart';

/// Design token palette for سوزوكي app.
/// Primary: Deep Blue  — authority, trust
/// Accent:  Amber      — energy, action
/// Surface: Light Gray — clean, minimal
abstract final class AppColors {
  // ── Primary ───────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Accent / Amber ────────────────────────────────────────────────────────
  static const Color amber = Color(0xFFFFC107);
  static const Color amberDark = Color(0xFFFF8F00);
  static const Color onAmber = Color(0xFF1A1A1A);

  // ── Surface & Background ──────────────────────────────────────────────────
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color background = Color(0xFFF0F4F8);
  static const Color onSurface = Color(0xFF1A1A2E);
  static const Color onBackground = Color(0xFF1A1A2E);

  // ── Grey Scale ────────────────────────────────────────────────────────────
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFD32F2F);
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
}
