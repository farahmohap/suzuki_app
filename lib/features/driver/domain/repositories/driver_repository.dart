import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/driver_entities.dart';

abstract class DriverRepository {
  Future<Either<Failure, DriverStatusEntity>> getDriverStatus();
  Future<Either<Failure, DriverStatusEntity>> updateDriverStatus(DriverStatus status);
  Future<Either<Failure, ActiveRouteEntity?>> getActiveRoute();
  Future<Either<Failure, bool>> updateSeatAvailability({
    required String routeId,
    required int seatNumber,
    required bool isOccupied,
  });
  Future<Either<Failure, EarningsEntity>> getEarnings({String period = 'today'});
}
