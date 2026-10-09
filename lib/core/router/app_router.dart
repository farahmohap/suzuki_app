import 'package:go_router/go_router.dart';
import 'package:suzuki_app/features/auth/presentation/screens/driver_register_screen.dart';
import 'package:suzuki_app/features/auth/presentation/screens/login_screen.dart';
import 'package:suzuki_app/features/auth/presentation/screens/otp_screen.dart';
import 'package:suzuki_app/features/auth/presentation/screens/passenger_register_screen.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoute.login.path,
  routes: [
    GoRoute(
      path: AppRoute.login.path,
      name: AppRoute.login.routeName,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoute.otp.path,
      name: AppRoute.otp.routeName,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return OtpVerificationScreen(
          phoneNumber: extra['phone'] ?? '',
          isDriver: extra['isDriver'] ?? false,
        );
      },
    ),
    // 👈 مسار التسجيل الديناميكي بناءً على دور المستخدم
    GoRoute(
      path: AppRoute.register.path,
      name: AppRoute.register.routeName,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final role = extra['role'] ?? 'passenger';

        if (role == 'driver') {
          return const DriverRegisterScreen();
        }
        return const PassengerRegisterScreen();
      },
    ),
  ],
);