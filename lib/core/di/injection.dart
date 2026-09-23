import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'injection.config.dart';

/// Global [GetIt] service locator instance.
final getIt = GetIt.instance;

/// Bootstraps all injectable dependencies.
/// Call once in [main] before [runApp].
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async => getIt.init();

/// Registers external/async dependencies that injectable cannot auto-detect.
/// Called inside the generated [init] extension but listed here for clarity.
@module
abstract class RegisterModule {
  /// [SharedPreferences] — resolved asynchronously before app starts.
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  /// [Dio] — the configured HTTP client singleton.
  @lazySingleton
  Dio get dio => _buildDio();

  Dio _buildDio() {
    return Dio(
      BaseOptions(
        baseUrl: 'https://api.suzuki-app.sa/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Language': 'ar',
        },
      ),
    );
  }
}

class RegisterModuleImpl extends RegisterModule {}
