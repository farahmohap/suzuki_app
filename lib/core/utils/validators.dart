/// Input validation utilities for سوزوكي app.
/// All error messages returned in Arabic.
abstract final class AppValidators {
  /// Converts Arabic-Indic / Persian digits to ASCII so validation and the
  /// API always see 0-9.
  static String toAsciiDigits(String input) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    final b = StringBuffer();
    for (final ch in input.runes) {
      final c = String.fromCharCode(ch);
      final a = arabic.indexOf(c);
      final p = persian.indexOf(c);
      b.write(a >= 0 ? '$a' : (p >= 0 ? '$p' : c));
    }
    return b.toString();
  }

  /// Local Egyptian mobile number: 010 / 011 / 012 / 015 + 8 digits.
  /// Accepts +20 / 0020 prefixes and spaces.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'رقم الموبايل مطلوب';
    if (normalizePhone(value) == null) {
      return 'أدخل رقم موبايل مصري صحيح (مثال: 01012345678)';
    }
    return null;
  }

  /// Returns `+201XXXXXXXXX` or null when [raw] is not a valid Egyptian mobile.
  static String? normalizePhone(String raw) {
    var d = toAsciiDigits(raw).replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('0020')) d = d.substring(4);
    if (d.startsWith('20') && d.length == 12) d = d.substring(2);
    if (d.length == 10 && d.startsWith('1')) d = '0$d';
    if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(d)) return null;
    return '+20${d.substring(1)}';
  }

  /// Egyptian national ID: 14 digits.
  static String? nationalId(String? value) {
    final v = toAsciiDigits(value ?? '').trim();
    if (v.isEmpty) return 'الرقم القومي مطلوب';
    if (!RegExp(r'^\d{14}$').hasMatch(v)) return 'الرقم القومي يجب أن يكون 14 رقم';
    return null;
  }

  /// Plate numbers part: 1–4 digits.
  static String? plateNumbers(String? value) {
    final v = toAsciiDigits(value ?? '').trim();
    if (v.isEmpty) return 'أرقام اللوحة مطلوبة';
    if (!RegExp(r'^\d{1,4}$').hasMatch(v)) return 'من 1 إلى 4 أرقام';
    return null;
  }

  /// Plate letters part: 2–3 Arabic letters (spaces allowed).
  static String? plateLetters(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'حروف اللوحة مطلوبة';
    if (!RegExp(r'^[\u0621-\u064A](\s?[\u0621-\u064A]){1,2}$').hasMatch(v)) {
      return 'من 2 إلى 3 حروف عربية';
    }
    return null;
  }

  /// Age in years (adults + teens allowed to ride with guardians: 14–90).
  static String? age(String? value) {
    final v = int.tryParse(toAsciiDigits(value ?? '').trim());
    if (v == null) return 'السن مطلوب';
    if (v < 14 || v > 90) return 'أدخل سنًا صحيحًا';
    return null;
  }

  /// Password: minimum 8 characters.
  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    return null;
  }

  /// Confirm password matches original.
  static String? Function(String?) confirmPassword(String original) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return 'تأكيد كلمة المرور مطلوب';
      if (value != original) return 'كلمتا المرور غير متطابقتين';
      return null;
    };
  }

  /// OTP: exactly 6 digits.
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return 'رمز التحقق مطلوب';
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'رمز التحقق يجب أن يكون 6 أرقام';
    }
    return null;
  }

  /// Generic required-field validator.
  static String? required(String? value, {String label = 'هذا الحقل'}) {
    if (value == null || value.trim().isEmpty) return '$label مطلوب';
    return null;
  }

  /// Full name: at least 3 characters.
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'الاسم مطلوب';
    if (value.trim().length < 3) return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    return null;
  }

  /// Minimum character length.
  static String? Function(String?) minLength(int min, {String label = 'الحقل'}) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) return '$label مطلوب';
      if (value.trim().length < min) return '$label يجب أن يكون $min أحرف على الأقل';
      return null;
    };
  }
}
