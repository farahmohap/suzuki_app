import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Extension helpers to apply [flutter_screenutil] responsive sizing
/// with semantic names throughout the codebase.
///
/// Design reference: 390×844 pt (iPhone 14 base).
extension ScreenUtilX on num {
  /// Width — scales relative to design width (390)
  double get w => toDouble().w;

  /// Height — scales relative to design height (844)
  double get h => toDouble().h;

  /// Font size — scales with screen width
  double get sp => toDouble().sp;

  /// Radius — scales with the minimum of width/height
  double get r => toDouble().r;

  /// Horizontal symmetrical padding
  double get pw => toDouble().w;

  /// Vertical symmetrical padding
  double get ph => toDouble().h;
}

/// Semantic spacing tokens in logical pixels,
/// converted to responsive values via [flutter_screenutil].
abstract final class AppSpacing {
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get xxl => 48.w;
  static double get xxxl => 64.w;

  // Vertical rhythm
  static double get vxs => 4.h;
  static double get vsm => 8.h;
  static double get vmd => 16.h;
  static double get vlg => 24.h;
  static double get vxl => 32.h;
  static double get vxxl => 48.h;
}

/// Border radius tokens.
abstract final class AppRadius {
  static double get xs => 4.r;
  static double get sm => 8.r;
  static double get md => 12.r;
  static double get lg => 16.r;
  static double get xl => 24.r;
  static double get full => 100.r;
}
