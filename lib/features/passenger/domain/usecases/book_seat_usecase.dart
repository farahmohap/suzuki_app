import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/seat_booking_entity.dart';
import '../repositories/passenger_repository.dart';

/// Books a specific seat on a route for the current passenger.
@injectable
class BookSeatUseCase {
  const BookSeatUseCase(this._repository);

  final PassengerRepository _repository;

  Future<Either<Failure, SeatBookingEntity>> call({
    required String routeId,
    required int seatNumber,
  }) {
    if (routeId.trim().isEmpty) {
      return Future.value(
        Left(const ValidationFailure(message: 'معرّف المسار غير صحيح')),
      );
    }
    if (seatNumber < 1) {
      return Future.value(
        Left(const ValidationFailure(message: 'رقم المقعد غير صحيح')),
      );
    }
    return _repository.bookSeat(routeId: routeId, seatNumber: seatNumber);
  }
}
