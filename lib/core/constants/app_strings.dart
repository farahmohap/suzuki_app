/// Centralised string constants for سوزوكي app.
/// All user-facing strings are in Arabic (RTL primary locale).
abstract final class AppStrings {
  // ── App ───────────────────────────────────────────────────────────────────
  static const String appName = 'سوزوكي';
  static const String appTagline = 'تنقل ذكي، وصول سريع';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = 'تسجيل الدخول';
  static const String register = 'إنشاء حساب';
  static const String phone = 'رقم الجوال';
  static const String password = 'كلمة المرور';
  static const String confirmPassword = 'تأكيد كلمة المرور';
  static const String fullName = 'الاسم الكامل';
  static const String otp = 'رمز التحقق';
  static const String otpSent = 'تم إرسال رمز التحقق إلى';
  static const String otpResend = 'إعادة إرسال الرمز';
  static const String otpCountdown = 'إعادة الإرسال خلال';
  static const String verifyOtp = 'تحقق من الرمز';
  static const String passenger = 'راكب';
  static const String driver = 'سائق';
  static const String selectRole = 'اختر نوع حسابك';
  static const String haveAccount = 'لديك حساب؟';
  static const String noAccount = 'ليس لديك حساب؟';
  static const String logout = 'تسجيل الخروج';

  // ── Passenger ─────────────────────────────────────────────────────────────
  static const String nearbyRoutes = 'المسارات القريبة';
  static const String bookSeat = 'احجز مقعدًا';
  static const String seatsAvailable = 'مقاعد متاحة';
  static const String noSeatsAvailable = 'لا توجد مقاعد متاحة';
  static const String trackDriver = 'تتبع السائق';
  static const String savedLandmarks = 'المعالم المحفوظة';
  static const String addLandmark = 'إضافة معلم';
  static const String landmarkName = 'اسم المعلم';
  static const String confirmBooking = 'تأكيد الحجز';
  static const String activeTrip = 'الرحلة النشطة';
  static const String arrivalTime = 'وقت الوصول المتوقع';
  static const String profile = 'الملف الشخصي';

  // ── Driver ────────────────────────────────────────────────────────────────
  static const String dashboard = 'لوحة التحكم';
  static const String goOnline = 'بدء العمل';
  static const String goOffline = 'إيقاف العمل';
  static const String activeRoute = 'المسار الحالي';
  static const String earnings = 'الأرباح';
  static const String todayEarnings = 'أرباح اليوم';
  static const String weeklyEarnings = 'أرباح الأسبوع';
  static const String totalTrips = 'إجمالي الرحلات';
  static const String seatManagement = 'إدارة المقاعد';
  static const String vehicleSeats = 'مقاعد السيارة';

  // ── Common ────────────────────────────────────────────────────────────────
  static const String confirm = 'تأكيد';
  static const String cancel = 'إلغاء';
  static const String save = 'حفظ';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String retry = 'إعادة المحاولة';
  static const String loading = 'جارٍ التحميل...';
  static const String noData = 'لا توجد بيانات';
  static const String search = 'بحث';

  // ── Errors ────────────────────────────────────────────────────────────────
  static const String errorGeneric = 'حدث خطأ ما، يرجى المحاولة لاحقًا';
  static const String errorNetwork = 'تحقق من اتصالك بالإنترنت';
  static const String errorServer = 'خطأ في الخادم، يرجى المحاولة لاحقًا';
  static const String errorAuth = 'بيانات الدخول غير صحيحة';
  static const String errorCache = 'تعذّر تحميل البيانات المحلية';
  static const String errorRequired = 'هذا الحقل مطلوب';
  static const String errorPhoneFormat = 'رقم الجوال غير صحيح';
  static const String errorPasswordLength = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
  static const String errorPasswordMatch = 'كلمتا المرور غير متطابقتين';
  static const String errorOtpLength = 'رمز التحقق يجب أن يكون 6 أرقام';
}
