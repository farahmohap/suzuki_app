import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../session/session_events.dart';
import '../storage/token_storage.dart';
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

/// External/async dependencies injectable cannot auto-detect.
@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @lazySingleton
FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
  /// The ONE configured Dio (with auth + refresh interceptors).
  @lazySingleton
  Dio dio(TokenStorage tokens, SessionEvents session) =>
      buildApiDio(tokens: tokens, session: session);
}

class RegisterModuleImpl extends RegisterModule {}
