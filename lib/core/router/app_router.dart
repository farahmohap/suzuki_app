import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/driver/presentation/screens/driver_dashboard_screen.dart';
import '../../features/driver/presentation/screens/driver_earnings_screen.dart';
import '../../features/driver/presentation/screens/driver_trip_screen.dart';
import '../../features/driver_onboarding/presentation/screens/driver_onboarding_screen.dart';
import '../../features/driver_onboarding/presentation/screens/driver_status_screen.dart';
import '../../features/passenger/presentation/screens/active_tracking_screen.dart';
import '../../features/passenger/presentation/screens/passenger_home_screen.dart';
import '../../features/passenger/presentation/screens/passenger_profile_screen.dart';
import '../../features/passenger/presentation/screens/seat_booking_screen.dart';
import '../../features/profile/presentation/screens/passenger_profile_setup_screen.dart';
import 'app_routes.dart';
import 'auth_redirect.dart';
import 'go_router_refresh_stream.dart';

/// Builds the app router. Redirects are driven by [auth] (see
/// [resolveRedirect]); identity travels in path params, not `extra`,
/// except the transient OTP screen arguments.
GoRouter createAppRouter(AuthCubit auth) {
  return GoRouter(
    initialLocation: AppRoute.splash.path,
    refreshListenable: GoRouterRefreshStream(auth.stream),
    redirect: (context, state) => resolveRedirect(
      resolved: auth.isResolved,
      user: auth.currentUser,
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.routeName,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.routeName,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.otp.path,
        name: AppRoute.otp.routeName,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpVerificationScreen(
            phoneNumber: extra['phone'] as String? ?? '',
            isDriver: extra['isDriver'] as bool? ?? false,
          );
        },
      ),
      // Passenger profile setup (first login). Guarded by resolveRedirect.
      GoRoute(
        path: AppRoute.register.path,
        name: AppRoute.register.routeName,
        builder: (_, _) => const PassengerProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoute.passengerShell.path,
        redirect: (_, state) =>
            state.uri.path == AppRoute.passengerShell.path
                ? AppRoute.passengerHome.fullPath
                : null,
        routes: [
          GoRoute(
            path: AppRoute.passengerHome.path,
            name: AppRoute.passengerHome.routeName,
            builder: (_, _) => const PassengerHomeScreen(),
          ),
          GoRoute(
            path: AppRoute.seatBooking.path,
            name: AppRoute.seatBooking.routeName,
            builder: (_, state) =>
                SeatBookingScreen(routeId: state.pathParameters['routeId']!),
          ),
          GoRoute(
            path: AppRoute.activeTracking.path,
            name: AppRoute.activeTracking.routeName,
            builder: (_, state) => ActiveTrackingScreen(
              bookingId: state.pathParameters['bookingId']!,
            ),
          ),
          GoRoute(
            path: AppRoute.passengerProfile.path,
            name: AppRoute.passengerProfile.routeName,
            builder: (_, _) => const PassengerProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.driverShell.path,
        redirect: (_, state) =>
            state.uri.path == AppRoute.driverShell.path
                ? AppRoute.driverDashboard.fullPath
                : null,
        routes: [
          GoRoute(
            path: AppRoute.driverOnboarding.path,
            name: AppRoute.driverOnboarding.routeName,
            builder: (_, _) => const DriverOnboardingScreen(),
          ),
          GoRoute(
            path: AppRoute.driverStatus.path,
            name: AppRoute.driverStatus.routeName,
            builder: (_, _) => const DriverStatusScreen(),
          ),
          GoRoute(
            path: AppRoute.driverDashboard.path,
            name: AppRoute.driverDashboard.routeName,
            builder: (_, _) => const DriverDashboardScreen(),
          ),
          GoRoute(
            path: AppRoute.driverTrip.path,
            name: AppRoute.driverTrip.routeName,
            builder: (_, state) =>
                DriverTripScreen(tripId: state.pathParameters['tripId']!),
          ),
          GoRoute(
            path: AppRoute.driverEarnings.path,
            name: AppRoute.driverEarnings.routeName,
            builder: (_, _) => const DriverEarningsScreen(),
          ),
        ],
      ),
    ],
  );
}
