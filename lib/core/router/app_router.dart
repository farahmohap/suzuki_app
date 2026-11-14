import 'package:flutter/material.dart';

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
import 'routing_animation.dart';

class AppRouters {
  AppRouters._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final RouteObserver<PageRoute<dynamic>> routeObserver =
      RouteObserver<PageRoute<dynamic>>();
  static final _currentRouteObserver = _CurrentRouteObserver();
  static AuthCubit? _auth;

  static void configure(AuthCubit auth) => _auth = auth;

  static String? get currentRouteName => _currentRouteObserver.currentRouteName;

  static List<NavigatorObserver> get observers => [
    routeObserver,
    _currentRouteObserver,
  ];

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final auth = _auth;
    final redirect = auth == null
        ? null
        : resolveRedirect(
            resolved: auth.isResolved,
            user: auth.currentUser,
            location: settings.name ?? RoutesName.splashScreen,
            isNewUser: auth.isNewUser,
          );
    if (redirect != null && redirect != settings.name) {
      return onGenerateRoute(RouteSettings(name: redirect));
    }

    final args = settings.arguments;
    switch (settings.name) {
      case RoutesName.splashScreen:
        return buildRoute(page: const SplashScreen(), settings: settings);
      case RoutesName.loginScreen:
        return buildRoute(page: const LoginScreen(), settings: settings);
      case RoutesName.otpScreen:
        final arguments = args is Map ? args : const {};
        return buildRoute(
          page: OtpVerificationScreen(
            phoneNumber: arguments['phone'] as String? ?? '',
            isDriver: arguments['isDriver'] as bool? ?? false,
          ),
          settings: settings,
          animation: RouteAnimation.fadeScale,
        );
      case RoutesName.registerScreen:
        return buildRoute(
          page: const PassengerProfileSetupScreen(),
          settings: settings,
        );
      case RoutesName.passengerHomeScreen:
        return buildRoute(
          page: const PassengerHomeScreen(),
          settings: settings,
        );
      case RoutesName.seatBookingScreen:
        final routeId = _stringArgument(args, 'routeId');
        if (routeId == null) return _unknownRoute(settings);
        return buildRoute(
          page: SeatBookingScreen(routeId: routeId),
          settings: settings,
          animation: RouteAnimation.slideRight,
        );
      case RoutesName.activeTrackingScreen:
        final bookingId = _stringArgument(args, 'bookingId');
        if (bookingId == null) return _unknownRoute(settings);
        return buildRoute(
          page: ActiveTrackingScreen(bookingId: bookingId),
          settings: settings,
          animation: RouteAnimation.fade,
        );
      case RoutesName.passengerProfileScreen:
        return buildRoute(
          page: const PassengerProfileScreen(),
          settings: settings,
        );
      case RoutesName.driverDashboardScreen:
        return buildRoute(
          page: const DriverDashboardScreen(),
          settings: settings,
        );
      case RoutesName.driverTripScreen:
        final tripId = _stringArgument(args, 'tripId');
        if (tripId == null) return _unknownRoute(settings);
        return buildRoute(
          page: DriverTripScreen(tripId: tripId),
          settings: settings,
          animation: RouteAnimation.slideUp,
        );
      case RoutesName.driverEarningsScreen:
        return buildRoute(
          page: const DriverEarningsScreen(),
          settings: settings,
        );
      case RoutesName.driverOnboardingScreen:
        return buildRoute(
          page: const DriverOnboardingScreen(),
          settings: settings,
        );
      case RoutesName.driverStatusScreen:
        return buildRoute(
          page: const DriverStatusScreen(),
          settings: settings,
        );
      default:
        return _unknownRoute(settings);
    }
  }

  static void syncAuthRoute({required String? destination}) {
    final navigator = navigatorKey.currentState;
    if (navigator == null || destination == null) return;
    if (currentRouteName == destination) return;
    navigator.pushNamedAndRemoveUntil(destination, (_) => false);
  }

  static String? _stringArgument(Object? args, String key) {
    if (args is Map) return args[key]?.toString();
    return null;
  }

  static Route<dynamic> _unknownRoute(RouteSettings settings) =>
      buildRoute(
        page: const Scaffold(
          body: Center(child: Text('الصفحة غير موجودة')),
        ),
        settings: settings,
      );
}

class _CurrentRouteObserver extends NavigatorObserver {
  String? currentRouteName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRouteName = route.settings.name;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRouteName = previousRoute?.settings.name;
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    currentRouteName = newRoute?.settings.name;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
