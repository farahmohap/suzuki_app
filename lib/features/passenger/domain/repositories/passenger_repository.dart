import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/landmark_entity.dart';
import '../entities/route_entity.dart';
import '../entities/seat_booking_entity.dart';

/// Contract for all passenger-facing data operations.
abstract class PassengerRepository {
  /// Fetches available Suzuki routes near [latitude]/[longitude].
  Future<Either<Failure, List<RouteEntity>>> getAvailableRoutes({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  });

  /// Books a seat on [routeId] for seat number [seatNumber].
  Future<Either<Failure, SeatBookingEntity>> bookSeat({
    required String routeId,
    required int seatNumber,
  });

  /// Gets the passenger's active booking (if any).
  Future<Either<Failure, SeatBookingEntity?>> getActiveBooking();

  /// Cancels the booking with [bookingId].
  Future<Either<Failure, bool>> cancelBooking({required String bookingId});

  /// Fetches all saved landmarks for the current user.
  Future<Either<Failure, List<LandmarkEntity>>> getSavedLandmarks();

  /// Saves a new [landmark] to local + remote storage.
  Future<Either<Failure, LandmarkEntity>> saveLandmark(
      LandmarkEntity landmark);

  /// Deletes the landmark with [landmarkId].
  Future<Either<Failure, bool>> deleteLandmark({required String landmarkId});
}
