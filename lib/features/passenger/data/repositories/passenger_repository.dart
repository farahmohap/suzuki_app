import 'package:fpdart/fpdart.dart';
import '../../../../core/network/failures.dart';
import '../models/passenger_models.dart';

/// Contract for all passenger-facing data operations returning Models directly.
abstract class PassengerRepository {
  /// Fetches available Suzuki routes near [latitude]/[longitude].
  Future<Either<Failure, List<RouteModel>>> getAvailableRoutes({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  });

  /// Books a seat on [routeId] for seat number [seatNumber].
  Future<Either<Failure, SeatBookingModel>> bookSeat({
    required String routeId,
    required int seatNumber,
  });

  /// Gets the passenger's active booking (if any).
  Future<Either<Failure, SeatBookingModel?>> getActiveBooking();

  /// Cancels the booking with [bookingId].
  Future<Either<Failure, bool>> cancelBooking({required String bookingId});

  /// Fetches all saved landmarks for the current user.
  Future<Either<Failure, List<LandmarkModel>>> getSavedLandmarks();

  /// Saves a new [landmark] to local + remote storage.
  Future<Either<Failure, LandmarkModel>> saveLandmark(LandmarkModel landmark);

  /// Deletes the landmark with [landmarkId].
  Future<Either<Failure, bool>> deleteLandmark({required String landmarkId});
}
