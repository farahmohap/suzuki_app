import 'package:intl/intl.dart';

/// Date and time formatting helpers for سوزوكي app.
/// Defaults to the Arabic locale; pass [locale] to override.
abstract final class DateFormatter {
  static const _arLocale = 'ar';

  /// e.g. "الثلاثاء، 23 سبتمبر 2026"
  static String fullDate(DateTime dt, {String locale = _arLocale}) =>
      DateFormat.yMMMMEEEEd(locale).format(dt);

  /// e.g. "23 سبتمبر 2026"
  static String longDate(DateTime dt, {String locale = _arLocale}) =>
      DateFormat.yMMMMd(locale).format(dt);

  /// e.g. "23/09/2026"
  static String shortDate(DateTime dt, {String locale = _arLocale}) =>
      DateFormat('dd/MM/yyyy', locale).format(dt);

  /// e.g. "06:45 م"
  static String time(DateTime dt, {String locale = _arLocale}) =>
      DateFormat.jm(locale).format(dt);

  /// e.g. "23 سبتمبر، 06:45 م"
  static String dateAndTime(DateTime dt, {String locale = _arLocale}) =>
      DateFormat('d MMMM، hh:mm a', locale).format(dt);

  /// Relative time — e.g. "منذ 3 دقائق", "منذ ساعة"
  static String relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return 'منذ $m ${_minuteLabel(m)}';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return 'منذ $h ${_hourLabel(h)}';
    }
    final d = diff.inDays;
    return 'منذ $d ${_dayLabel(d)}';
  }

  /// Formats seconds as MM:SS countdown string — useful for OTP timer.
  static String countdown(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Arabic plural helpers ───────────────────────────────────────────────
  static String _minuteLabel(int n) => n == 1 ? 'دقيقة' : 'دقائق';
  static String _hourLabel(int n) => n == 1 ? 'ساعة' : 'ساعات';
  static String _dayLabel(int n) => n == 1 ? 'يوم' : 'أيام';
}
