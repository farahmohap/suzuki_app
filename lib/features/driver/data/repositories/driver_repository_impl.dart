import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/driver_entities.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_remote_data_source.dart';

@LazySingleton(as: DriverRepository)
class DriverRepositoryImpl implements DriverRepository {
  const DriverRepositoryImpl({
    required DriverRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remote = remoteDataSource,
        _network = networkInfo;

  final DriverRemoteDataSource _remote;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, DriverStatusEntity>> getDriverStatus() =>
      _guard(() => _remote.getDriverStatus());

  @override
  Future<Either<Failure, DriverStatusEntity>> updateDriverStatus(
      DriverStatus status) =>
      _guard(() => _remote.updateDriverStatus(status));

  @override
  Future<Either<Failure, ActiveRouteEntity?>> getActiveRoute() =>
      _guard(() => _remote.getActiveRoute());

  @override
  Future<Either<Failure, bool>> updateSeatAvailability({
    required String routeId,
    required int seatNumber,
    required bool isOccupied,
  }) =>
      _guard(() => _remote.updateSeatAvailability(
            routeId: routeId,
            seatNumber: seatNumber,
            isOccupied: isOccupied,
          ));

  @override
  Future<Either<Failure, EarningsEntity>> getEarnings(
          {String period = 'today'}) =>
      _guard(() => _remote.getEarnings(period: period));

  // ── Helper ──────────────────────────────────────────────────────────────
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() fn) async {
    if (!await _network.isConnected) return const Left(NetworkFailure());
    try {
      final result = await fn();
      return Right(result);
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
}
