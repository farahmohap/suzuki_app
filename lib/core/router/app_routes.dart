/// Named app routes for GoRouter.
/// Each value has a [path] (URL fragment) and [routeName] (for named navigation).
enum AppRoute {
  // ── Auth ───────────────────────────────────────────────────────────────────
  login(path: '/login', routeName: 'login'),
  register(path: '/register', routeName: 'register'),
  otp(path: '/otp', routeName: 'otp'),

  // ── Passenger Shell ────────────────────────────────────────────────────────
  passengerShell(path: '/passenger', routeName: 'passenger-shell'),
  passengerHome(path: 'home', routeName: 'passenger-home'),
  seatBooking(path: 'book/:routeId', routeName: 'seat-booking'),
  activeTracking(path: 'tracking/:bookingId', routeName: 'active-tracking'),
  passengerProfile(path: 'profile', routeName: 'passenger-profile'),

  // ── Driver Shell ───────────────────────────────────────────────────────────
  driverShell(path: '/driver', routeName: 'driver-shell'),
  driverDashboard(path: 'dashboard', routeName: 'driver-dashboard'),
  driverTrip(path: 'trip/:tripId', routeName: 'driver-trip'),
  driverEarnings(path: 'earnings', routeName: 'driver-earnings'),

  // ── Shared ─────────────────────────────────────────────────────────────────
  splash(path: '/', routeName: 'splash');

  const AppRoute({required this.path, required this.routeName});

  final String path;
  final String routeName;
}

extension AppRouteX on AppRoute {
  /// Absolute path for use with [GoRouter.go] or Deep Links.
  String get fullPath {
    switch (this) {
      case AppRoute.passengerHome:
        return '/passenger/home';
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

  /// Helper method for parameterized dynamic full paths
  String parameterizedPath(Map<String, String> params) {
    String result = fullPath;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value);
    });
    return result;
  }
}