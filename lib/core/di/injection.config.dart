// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_local_data_source.dart'
    as _i852;
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository.dart' as _i573;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/driver/data/datasources/driver_remote_data_source.dart'
    as _i575;
import '../../features/driver/data/repositories/driver_repository.dart' as _i4;
import '../../features/driver/data/repositories/driver_repository_impl.dart'
    as _i892;
import '../../features/driver/presentation/cubit/driver_cubit.dart' as _i727;
import '../../features/driver_onboarding/data/datasources/driver_onboarding_remote_data_source.dart'
    as _i923;
import '../../features/driver_onboarding/data/repositories/driver_onboarding_repository.dart'
    as _i647;
import '../../features/driver_onboarding/presentation/cubit/driver_onboarding_cubit.dart'
    as _i22;
import '../../features/driver_onboarding/presentation/cubit/driver_status_cubit.dart'
    as _i855;
import '../../features/passenger/data/datasources/passenger_local_data_source.dart'
    as _i412;
import '../../features/passenger/data/datasources/passenger_remote_data_source.dart'
    as _i658;
import '../../features/passenger/data/repositories/passenger_repository.dart'
    as _i621;
import '../../features/passenger/data/repositories/passenger_repository_impl.dart'
    as _i715;
import '../../features/passenger/presentation/cubit/passenger_cubits.dart'
    as _i863;
import '../../features/profile/data/datasources/profile_remote_data_source.dart'
    as _i847;
import '../../features/profile/data/repositories/profile_repository.dart'
    as _i361;
import '../../features/profile/presentation/cubit/profile_cubit.dart' as _i36;
import '../network/network_info.dart' as _i932;
import '../network/socket_service.dart' as _i917;
import '../session/session_events.dart' as _i893;
import '../storage/token_storage.dart' as _i973;
import 'injection.dart' as _i464;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
        () => registerModule.secureStorage);
    gh.lazySingleton<_i893.SessionEvents>(() => _i893.SessionEvents());
    gh.lazySingleton<_i932.NetworkInfo>(() => const _i932.NetworkInfoImpl());
    gh.lazySingleton<_i412.PassengerLocalDataSource>(
        () => _i412.PassengerLocalDataSourceImpl());
    gh.lazySingleton<_i973.TokenStorage>(
        () => _i973.SecureTokenStorage(gh<_i558.FlutterSecureStorage>()));
    gh.lazySingleton<_i852.AuthLocalDataSource>(
        () => _i852.AuthLocalDataSourceImpl(
              gh<_i460.SharedPreferences>(),
              gh<_i973.TokenStorage>(),
            ));
    gh.lazySingleton<_i917.SocketService>(
        () => _i917.SocketService(gh<_i973.TokenStorage>()));
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio(
          gh<_i973.TokenStorage>(),
          gh<_i893.SessionEvents>(),
        ));
    gh.lazySingleton<_i923.DriverOnboardingRemoteDataSource>(
        () => _i923.DriverOnboardingRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i575.DriverRemoteDataSource>(
        () => _i575.DriverRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
        () => _i107.AuthRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i658.PassengerRemoteDataSource>(
        () => _i658.PassengerRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i4.DriverRepository>(() => _i892.DriverRepositoryImpl(
          remoteDataSource: gh<_i575.DriverRemoteDataSource>(),
          networkInfo: gh<_i932.NetworkInfo>(),
        ));
    gh.lazySingleton<_i847.ProfileRemoteDataSource>(
        () => _i847.ProfileRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.lazySingleton<_i573.AuthRepository>(() => _i153.AuthRepositoryImpl(
          remoteDataSource: gh<_i107.AuthRemoteDataSource>(),
          localDataSource: gh<_i852.AuthLocalDataSource>(),
          networkInfo: gh<_i932.NetworkInfo>(),
        ));
    gh.lazySingleton<_i621.PassengerRepository>(
        () => _i715.PassengerRepositoryImpl(
              remoteDataSource: gh<_i658.PassengerRemoteDataSource>(),
              localDataSource: gh<_i412.PassengerLocalDataSource>(),
              networkInfo: gh<_i932.NetworkInfo>(),
            ));
    gh.lazySingleton<_i647.DriverOnboardingRepository>(
        () => _i647.DriverOnboardingRepositoryImpl(
              gh<_i923.DriverOnboardingRemoteDataSource>(),
              gh<_i932.NetworkInfo>(),
            ));
    gh.lazySingleton<_i361.ProfileRepository>(() => _i361.ProfileRepositoryImpl(
          gh<_i847.ProfileRemoteDataSource>(),
          gh<_i932.NetworkInfo>(),
        ));
    gh.factory<_i863.BookingCubit>(() => _i863.BookingCubit(
        passengerRepository: gh<_i621.PassengerRepository>()));
    gh.factory<_i863.LandmarkCubit>(() => _i863.LandmarkCubit(
        passengerRepository: gh<_i621.PassengerRepository>()));
    gh.factory<_i727.DriverCubit>(
        () => _i727.DriverCubit(driverRepository: gh<_i4.DriverRepository>()));
    gh.factory<_i36.ProfileCubit>(
        () => _i36.ProfileCubit(gh<_i361.ProfileRepository>()));
    gh.lazySingleton<_i117.AuthCubit>(() => _i117.AuthCubit(
          gh<_i573.AuthRepository>(),
          gh<_i893.SessionEvents>(),
        ));
    gh.factory<_i22.DriverOnboardingCubit>(() => _i22.DriverOnboardingCubit(
          gh<_i647.DriverOnboardingRepository>(),
          gh<_i361.ProfileRepository>(),
        ));
    gh.factory<_i855.DriverStatusCubit>(
        () => _i855.DriverStatusCubit(gh<_i647.DriverOnboardingRepository>()));
    return this;
  }
}

class _$RegisterModule extends _i464.RegisterModule {}
