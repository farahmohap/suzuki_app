import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suzuki_app/features/driver/presentation/screens/driver_dashboard_screen.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const SuzukiApp());
}

class SuzukiApp extends StatelessWidget {
  const SuzukiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          //routerConfig: AppRouter.router,
         home: DriverDashboardScreen(),
        );
      },
    );
  }
}
