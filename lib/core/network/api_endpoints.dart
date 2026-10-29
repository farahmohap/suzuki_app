/// All REST API endpoint paths (relative to [AppConfig.apiBaseUrl]).
/// Names follow the Backend Development Plan, section 4.
abstract final class ApiEndpoints {
  // ── Auth (phase 1) ─────────────────────────────────────────────────────────
  static const String otpRequest = '/auth/otp/request';
  static const String otpVerify = '/auth/otp/verify';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String devices = '/devices';

  // ── Profile & shared (phase 2) ─────────────────────────────────────────────
  static const String me = '/users/me';
  static const String districts = '/districts';
  static const String presignUpload = '/uploads/presign';

  // ── Driver onboarding (phase 2) ────────────────────────────────────────────
  static const String driverStep1 = '/drivers/register/step1';
  static const String driverStep2 = '/drivers/register/step2';
  static const String driverStep3 = '/drivers/register/step3';
  static const String driverSubmit = '/drivers/register/submit';
  static const String driverVerificationStatus = '/drivers/me/status';
  static String driverDocument(String type) => '/drivers/me/documents/$type';

  // ── Phase 3+ (existing screens still use these; align when built) ──────────
  static const String availableRoutes = '/passenger/routes';
  static const String bookSeat = '/passenger/bookings';
  static const String activeBooking = '/passenger/bookings/active';
  static const String cancelBooking = '/passenger/bookings/cancel';
  static String bookingById(String id) => '/passenger/bookings/$id';

  static const String landmarks = '/passenger/landmarks';
  static String landmarkById(String id) => '/passenger/landmarks/$id';

  static const String driverStatus = '/driver/status';
  static const String driverActiveRoute = '/driver/routes/active';
  static const String updateSeats = '/driver/seats';
  static const String driverEarnings = '/driver/earnings';
  static String driverEarningsByPeriod(String period) =>
      '/driver/earnings?period=$period';

  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String uploadAvatar = '/user/avatar';
}
