import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_routes.dart';

// ── Feature Screen Imports ──────────────────────────────────────────────────
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/passenger/presentation/screens/passenger_home_screen.dart';
import '../../features/passenger/presentation/screens/seat_booking_screen.dart';
import '../../features/passenger/presentation/screens/active_tracking_screen.dart';
import '../../features/passenger/presentation/screens/passenger_profile_screen.dart';

/// Configured [GoRouter] for سوزوكي app.
///
/// Route guard:
///   • Unauthenticated → `/login`
///   • Authenticated as passenger → `/passenger/home`
///   • Authenticated as driver → `/driver/dashboard`
class AppRouter {
  AppRouter._();

  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';

  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: AppRoute.splash.path,
    debugLogDiagnostics: true,
    redirect: _guardRedirect,
    routes: [
      // ── Splash / Root redirect ─────────────────────────────────────────────
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (_, __) => const _SplashPage(),
      ),

      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.register.path,
        name: AppRoute.register.name,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoute.otp.path,
        name: AppRoute.otp.name,
        builder: (_, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),

      // ── Passenger Shell ───────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => _PassengerShell(child: child),
        routes: [
          GoRoute(
            path: AppRoute.passengerShell.path,
            redirect: (_, __) => '/passenger/home',
          ),
          GoRoute(
            path: '/passenger/home',
            name: AppRoute.passengerHome.name,
            builder: (_, __) => const PassengerHomeScreen(),
          ),
          GoRoute(
            path: '/passenger/book/:routeId',
            name: AppRoute.seatBooking.name,
            builder: (_, state) {
              final routeId = state.pathParameters['routeId']!;
              return SeatBookingScreen(routeId: routeId);
            },
          ),
          GoRoute(
            path: '/passenger/tracking/:bookingId',
            name: AppRoute.activeTracking.name,
            builder: (_, state) {
              final bookingId = state.pathParameters['bookingId']!;
              return ActiveTrackingScreen(bookingId: bookingId);
            },
          ),
          GoRoute(
            path: '/passenger/profile',
            name: AppRoute.passengerProfile.name,
            builder: (_, __) => const PassengerProfileScreen(),
          ),
        ],
      ),

      // ── Driver Shell ──────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => _DriverShell(child: child),
        routes: [
          GoRoute(
            path: AppRoute.driverShell.path,
            redirect: (_, __) => '/driver/dashboard',
          ),
          GoRoute(
            path: '/driver/dashboard',
            name: AppRoute.driverDashboard.name,
            builder: (_, __) => const DriverDashboardScreen(),
          ),
          GoRoute(
            path: '/driver/earnings',
            name: AppRoute.driverEarnings.name,
            builder: (_, __) => const DriverEarningsScreen(),
          ),
        ],
      ),
    ],
  );

  // ── Auth Guard ────────────────────────────────────────────────────────────
  static Future<String?> _guardRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final role = prefs.getString(_roleKey);

    final isAuth = token != null && token.isNotEmpty;
    final onAuthPage = state.matchedLocation == AppRoute.login.path ||
        state.matchedLocation == AppRoute.register.path ||
        state.matchedLocation == AppRoute.otp.path;

    if (!isAuth && !onAuthPage) return AppRoute.login.path;
    if (isAuth && state.matchedLocation == AppRoute.splash.path) {
      return role == 'driver' ? '/driver/dashboard' : '/passenger/home';
    }
    return null;
  }
}

// ── Internal Shell Widgets ─────────────────────────────────────────────────

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _PassengerShell extends StatefulWidget {
  const _PassengerShell({required this.child});
  final Widget child;

  @override
  State<_PassengerShell> createState() => _PassengerShellState();
}

class _PassengerShellState extends State<_PassengerShell> {
  int _index = 0;

  final _tabs = [
    '/passenger/home',
    '/passenger/profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          context.go(_tabs[i]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'حسابي'),
        ],
      ),
    );
  }
}

class _DriverShell extends StatefulWidget {
  const _DriverShell({required this.child});
  final Widget child;

  @override
  State<_DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<_DriverShell> {
  int _index = 0;

  final _tabs = [
    '/driver/dashboard',
    '/driver/earnings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
          context.go(_tabs[i]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'لوحة التحكم'),
          NavigationDestination(icon: Icon(Icons.attach_money), label: 'الأرباح'),
        ],
      ),
    );
  }
}
