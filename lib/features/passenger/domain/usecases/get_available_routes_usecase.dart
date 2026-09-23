import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/route_entity.dart';
import '../repositories/passenger_repository.dart';

/// Fetches available routes within [radiusKm] of the user's location.
@injectable
class GetAvailableRoutesUseCase {
  const GetAvailableRoutesUseCase(this._repository);

  final PassengerRepository _repository;

  Future<Either<Failure, List<RouteEntity>>> call({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) {
    return _repository.getAvailableRoutes(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}
