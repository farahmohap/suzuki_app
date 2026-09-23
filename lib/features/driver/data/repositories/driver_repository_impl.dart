import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/driver_remote_data_source.dart';
import '../models/driver_models.dart';
import 'driver_repository.dart';

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
  Future<Either<Failure, DriverStatusModel>> getDriverStatus() =>
      _guard(() => _remote.getDriverStatus());

  @override
  Future<Either<Failure, DriverStatusModel>> updateDriverStatus(
          DriverStatus status) =>
      _guard(() => _remote.updateDriverStatus(status));

  @override
  Future<Either<Failure, ActiveRouteModel?>> getActiveRoute() =>
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
  Future<Either<Failure, EarningsModel>> getEarnings(
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
