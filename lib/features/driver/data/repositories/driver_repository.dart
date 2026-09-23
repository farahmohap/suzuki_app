import 'package:fpdart/fpdart.dart';
import '../../../../core/network/failures.dart';
import '../models/driver_models.dart';

abstract class DriverRepository {
  Future<Either<Failure, DriverStatusModel>> getDriverStatus();
  Future<Either<Failure, DriverStatusModel>> updateDriverStatus(DriverStatus status);
  Future<Either<Failure, ActiveRouteModel?>> getActiveRoute();
  Future<Either<Failure, bool>> updateSeatAvailability({
    required String routeId,
    required int seatNumber,
    required bool isOccupied,
  });
  Future<Either<Failure, EarningsModel>> getEarnings({String period = 'today'});
}
