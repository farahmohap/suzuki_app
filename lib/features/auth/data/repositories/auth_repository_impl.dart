import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_model.dart';

/// Concrete [AuthRepository] implementation.
///
/// Strategy:
///   • Checks network availability before every remote call.
///   • On success: persists token + user to [AuthLocalDataSource].
///   • Maps all exceptions to [Failure] subtypes via sealed class matching.
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
  Future<Either<Failure, AuthEntity>> login({
    required String phone,
    required String password,
  }) async {
    if (!await _network.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final model = await _remote.login(phone: phone, password: password);
      await _persistSession(model);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure.fromException(e));
    } on AuthException {
      return const Left(AuthFailure());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> register({
    required String phone,
    required String password,
    required String fullName,
    required String role,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final model = await _remote.register(
        phone: phone,
        password: password,
        fullName: fullName,
        role: role,
      );
      await _persistSession(model);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure.fromException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final model = await _remote.verifyOtp(phone: phone, otp: otp);
      await _persistSession(model);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure.fromException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> resendOtp({required String phone}) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final result = await _remote.resendOtp(phone: phone);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure.fromException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final token = await _local.getToken() ?? '';
      if (token.isNotEmpty && await _network.isConnected) {
        await _remote.logout(token: token);
      }
      await _local.clearSession();
      return const Right(true);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _local.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<AuthEntity?> getCachedUser() => _local.getCachedUser();

  // ── Private helpers ──────────────────────────────────────────────────────
  Future<void> _persistSession(AuthModel model) async {
    await Future.wait([
      _local.cacheUser(model),
      _local.saveToken(model.token, model.refreshToken),
      _local.saveRole(model.role.name),
    ]);
  }
}
