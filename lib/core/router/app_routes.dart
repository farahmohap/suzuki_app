/// Named app routes for GoRouter.
/// Each value has a [path] (URL fragment) and [name] (for named navigation).
enum AppRoute {
  // ── Auth ───────────────────────────────────────────────────────────────────
  login(path: '/login', name: 'login'),
  register(path: '/register', name: 'register'),
  otp(path: '/otp', name: 'otp'),

  // ── Passenger Shell ────────────────────────────────────────────────────────
  passengerShell(path: '/passenger', name: 'passenger-shell'),
  passengerHome(path: 'home', name: 'passenger-home'),
  seatBooking(path: 'book/:routeId', name: 'seat-booking'),
  activeTracking(path: 'tracking/:bookingId', name: 'active-tracking'),
  passengerProfile(path: 'profile', name: 'passenger-profile'),

  // ── Driver Shell ───────────────────────────────────────────────────────────
  driverShell(path: '/driver', name: 'driver-shell'),
  driverDashboard(path: 'dashboard', name: 'driver-dashboard'),
  driverEarnings(path: 'earnings', name: 'driver-earnings'),

  // ── Shared ─────────────────────────────────────────────────────────────────
  splash(path: '/', name: 'splash');

  const AppRoute({required this.path, required this.name});

  final String path;
  final String name;
}

extension AppRouteX on AppRoute {
  /// Absolute path for use with [GoRouter.go].
  String get fullPath {
    switch (this) {
      case AppRoute.passengerHome:
        return '/passenger/home';
      case AppRoute.seatBooking:
        return '/passenger/book/:routeId';
      case AppRoute.activeTracking:
        return '/passenger/tracking/:bookingId';
      case AppRoute.passengerProfile:
        return '/passenger/profile';
      case AppRoute.driverDashboard:
        return '/driver/dashboard';
      case AppRoute.driverEarnings:
        return '/driver/earnings';
      default:
        return path;
    }
  }
}
