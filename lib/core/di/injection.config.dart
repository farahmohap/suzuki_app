// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

/// This file is a PLACEHOLDER.
/// Run the following command to generate the real file:
///
///   dart run build_runner build --delete-conflicting-outputs
///
/// The generated code will register all classes annotated with
/// @injectable, @singleton, @lazySingleton, @factoryMethod, etc.

extension GetItInjectableX on _i174.GetIt {
  // ignore: unused_element
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );

    // ── Placeholder: run build_runner to populate this ──────────────────────
    // gh.lazySingleton<NetworkInfo>(() => NetworkInfoImpl());
    // gh.lazySingleton<AuthRemoteDataSource>(...)
    // gh.lazySingleton<AuthLocalDataSource>(...)
    // gh.lazySingleton<AuthRepository>(...)
    // gh.factory<LoginUseCase>(...)
    // ... etc

    return this;
  }
}
