import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/router/auth_redirect.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const SuzukiApp());
}

class SuzukiApp extends StatefulWidget {
  const SuzukiApp({super.key});

  @override
  State<SuzukiApp> createState() => _SuzukiAppState();
}

class _SuzukiAppState extends State<SuzukiApp> {
  late final AuthCubit _auth = getIt<AuthCubit>();
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    AppRouters.configure(_auth);
    _authSubscription = _auth.stream.listen(_syncAuthRoute);
  }

  void _syncAuthRoute(AuthState state) {
    final current = AppRouters.currentRouteName ?? RoutesName.splashScreen;
    if (state is AuthOffline) {
      AppRouters.syncAuthRoute(destination: RoutesName.splashScreen);
      return;
    }
    if (state is AuthUnauthenticated) {
      AppRouters.syncAuthRoute(destination: RoutesName.loginScreen);
      return;
    }
    if (state is AuthAuthenticated) {
      final destination = resolveRedirect(
        resolved: _auth.isResolved,
        user: _auth.currentUser,
        location: current,
        isNewUser: _auth.isNewUser,
      );
      if (destination != null) {
        AppRouters.syncAuthRoute(destination: destination);
      }
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: _auth,
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            navigatorKey: AppRouters.navigatorKey,
            navigatorObservers: AppRouters.observers,
            initialRoute: RoutesName.splashScreen,
            onGenerateRoute: AppRouters.onGenerateRoute,
            // Arabic is the primary language → RTL layout everywhere.
            locale: const Locale('ar', 'EG'),
            supportedLocales: const [Locale('ar', 'EG'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
