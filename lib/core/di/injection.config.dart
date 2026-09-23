// GENERATED CODE - MANUAL & INJECTABLE BOOTSTRAPPER
// ignore_for_file: type=lint
// coverage:ignore-file

import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_local_data_source.dart'
    as _i800;
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i801;
import '../../features/auth/data/repositories/auth_repository.dart' as _i802;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i803;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i804;
import '../../features/driver/data/datasources/driver_remote_data_source.dart'
    as _i900;
import '../../features/driver/data/repositories/driver_repository.dart'
    as _i901;
import '../../features/driver/data/repositories/driver_repository_impl.dart'
    as _i902;
import '../../features/driver/presentation/cubit/driver_cubit.dart' as _i903;
import '../../features/passenger/data/datasources/passenger_local_data_source.dart'
    as _i700;
import '../../features/passenger/data/datasources/passenger_remote_data_source.dart'
    as _i701;
import '../../features/passenger/data/repositories/passenger_repository.dart'
    as _i702;
import '../../features/passenger/data/repositories/passenger_repository_impl.dart'
    as _i703;
import '../../features/passenger/presentation/cubit/passenger_cubits.dart'
    as _i704;
import '../network/network_info.dart' as _i600;
import 'injection.dart' as _i100;

extension GetItInjectableX on _i174.GetIt {
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );

    final registerModule = _i100.RegisterModuleImpl();

    // Core & External
    final sharedPreferences = await registerModule.sharedPreferences;
    gh.factory<_i460.SharedPreferences>(() => sharedPreferences);
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i600.NetworkInfo>(() => const _i600.NetworkInfoImpl());

    // Auth
    gh.lazySingleton<_i800.AuthLocalDataSource>(
      () => _i800.AuthLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i801.AuthRemoteDataSource>(
      () => _i801.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i802.AuthRepository>(
      () => _i803.AuthRepositoryImpl(
        remoteDataSource: gh<_i801.AuthRemoteDataSource>(),
        localDataSource: gh<_i800.AuthLocalDataSource>(),
        networkInfo: gh<_i600.NetworkInfo>(),
      ),
    );
    gh.factory<_i804.AuthCubit>(
      () => _i804.AuthCubit(authRepository: gh<_i802.AuthRepository>()),
    );

    // Passenger
    gh.lazySingleton<_i700.PassengerLocalDataSource>(
      () => _i700.PassengerLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i701.PassengerRemoteDataSource>(
      () => _i701.PassengerRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i702.PassengerRepository>(
      () => _i703.PassengerRepositoryImpl(
        remoteDataSource: gh<_i701.PassengerRemoteDataSource>(),
        localDataSource: gh<_i700.PassengerLocalDataSource>(),
        networkInfo: gh<_i600.NetworkInfo>(),
      ),
    );
    gh.factory<_i704.BookingCubit>(
      () => _i704.BookingCubit(
        passengerRepository: gh<_i702.PassengerRepository>(),
      ),
    );
    gh.factory<_i704.LandmarkCubit>(
      () => _i704.LandmarkCubit(
        passengerRepository: gh<_i702.PassengerRepository>(),
      ),
    );

    // Driver
    gh.lazySingleton<_i900.DriverRemoteDataSource>(
      () => _i900.DriverRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i901.DriverRepository>(
      () => _i902.DriverRepositoryImpl(
        remoteDataSource: gh<_i900.DriverRemoteDataSource>(),
        networkInfo: gh<_i600.NetworkInfo>(),
      ),
    );
    gh.factory<_i903.DriverCubit>(
      () => _i903.DriverCubit(driverRepository: gh<_i901.DriverRepository>()),
    );

    return this;
  }
}
