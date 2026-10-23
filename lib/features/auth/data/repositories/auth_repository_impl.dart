import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/guard.dart';
import '../../../../core/network/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_model.dart';
import 'auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remote = remoteDataSource,
        _local = localDataSource,
        _network = networkInfo;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, Unit>> requestOtp({
    required String phone,
    required UserRole role,
  }) =>
      guardCall(_network, () async {
        await _remote.requestOtp(phone: phone, role: role);
        return unit;
      });

  @override
  Future<Either<Failure, AuthSession>> verifyOtp({
    required String phone,
    required String code,
  }) =>
      guardCall(_network, () async {
        final deviceId = await _local.getOrCreateDeviceId();
        final session = await _remote.verifyOtp(
          phone: phone,
          code: code,
          deviceId: deviceId,
        );
        await _local.saveSession(session);
        return session;
      });

  @override
  Future<Either<Failure, AuthModel>> refreshUser() =>
      guardCall(_network, () async {
        final user = await _remote.getMe();
        await _local.cacheUser(user);
        return user;
      });

  @override
  Future<void> logout() async {
    try {
      final refresh = await _local.getRefreshToken();
      if (refresh != null && await _network.isConnected) {
        await _remote.logout(refreshToken: refresh);
      }
    } catch (_) {
      // Best effort: local session is cleared regardless.
    }
    await _local.clearSession();
  }

  @override
  Future<AuthModel?> restoreSession() async {
    if (!await _local.hasTokens()) return null;
    return _local.getCachedUser();
  }

  @override
  Future<void> cacheUser(AuthModel user) => _local.cacheUser(user);
}
