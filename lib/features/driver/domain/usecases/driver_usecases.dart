import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/driver_entities.dart';
import '../repositories/driver_repository.dart';

@injectable
class UpdateDriverStatusUseCase {
  const UpdateDriverStatusUseCase(this._repository);
  final DriverRepository _repository;

  Future<Either<Failure, DriverStatusEntity>> call(DriverStatus status) =>
      _repository.updateDriverStatus(status);
}

@injectable
class GetActiveRouteUseCase {
  const GetActiveRouteUseCase(this._repository);
  final DriverRepository _repository;

  Future<Either<Failure, ActiveRouteEntity?>> call() =>
      _repository.getActiveRoute();
}

@injectable
class UpdateSeatAvailabilityUseCase {
  const UpdateSeatAvailabilityUseCase(this._repository);
  final DriverRepository _repository;

  Future<Either<Failure, bool>> call({
    required String routeId,
    required int seatNumber,
    required bool isOccupied,
  }) =>
      _repository.updateSeatAvailability(
        routeId: routeId,
        seatNumber: seatNumber,
        isOccupied: isOccupied,
      );
}

@injectable
class GetEarningsUseCase {
  const GetEarningsUseCase(this._repository);
  final DriverRepository _repository;

  Future<Either<Failure, EarningsEntity>> call({String period = 'today'}) =>
      _repository.getEarnings(period: period);
}
