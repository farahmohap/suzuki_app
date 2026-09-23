/// All REST API endpoint paths for سوزوكي backend.
/// Use [ApiEndpoints.baseUrl] + path for absolute URLs.
abstract final class ApiEndpoints {
  // ── Base ───────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://api.suzuki-app.sa/v1';

  // ── Auth ───────────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // ── Passenger ──────────────────────────────────────────────────────────────
  static const String availableRoutes = '/passenger/routes';
  static const String bookSeat = '/passenger/bookings';
  static const String activeBooking = '/passenger/bookings/active';
  static const String cancelBooking = '/passenger/bookings/cancel';
  static String bookingById(String id) => '/passenger/bookings/$id';

  static const String landmarks = '/passenger/landmarks';
  static String landmarkById(String id) => '/passenger/landmarks/$id';

  // ── Driver ─────────────────────────────────────────────────────────────────
  static const String driverStatus = '/driver/status';
  static const String driverActiveRoute = '/driver/routes/active';
  static const String updateSeats = '/driver/seats';
  static const String driverEarnings = '/driver/earnings';
  static String driverEarningsByPeriod(String period) =>
      '/driver/earnings?period=$period';

  // ── Shared ─────────────────────────────────────────────────────────────────
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String uploadAvatar = '/user/avatar';
}
