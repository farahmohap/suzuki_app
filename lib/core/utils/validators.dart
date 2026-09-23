/// Input validation utilities for سوزوكي app.
/// All error messages returned in Arabic.
abstract final class AppValidators {
  /// Phone number: Saudi format — starts with 05 and is 10 digits.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'رقم الجوال مطلوب';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^05[0-9]{8}$').hasMatch(digits)) {
      return 'أدخل رقم جوال سعودي صحيح (05xxxxxxxx)';
    }
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
