import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/passenger_models.dart';
import '../../data/repositories/passenger_repository.dart';
import 'passenger_states.dart';

/// Manages seat booking and route browsing state directly with [PassengerRepository].
@injectable
class BookingCubit extends Cubit<BookingState> {
  BookingCubit({
    required PassengerRepository passengerRepository,
  })  : _repo = passengerRepository,
        super(const BookingInitial());

  final PassengerRepository _repo;

  Future<void> loadRoutes({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    emit(const BookingLoading());
    final result = await _repo.getAvailableRoutes(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
    result.fold(
      (f) => emit(BookingError(f.message)),
      (routes) => emit(RoutesLoaded(routes)),
    );
  }

  Future<void> bookSeat({
    required String routeId,
    required int seatNumber,
  }) async {
    emit(const BookingLoading());
    final result = await _repo.bookSeat(routeId: routeId, seatNumber: seatNumber);
    result.fold(
      (f) => emit(BookingError(f.message)),
      (booking) => emit(SeatBooked(booking)),
    );
  }

  Future<void> loadActiveBooking() async {
    emit(const BookingLoading());
    final result = await _repo.getActiveBooking();
    result.fold(
      (f) => emit(BookingError(f.message)),
      (booking) => emit(ActiveBookingLoaded(booking)),
    );
  }

  Future<void> cancelBooking({required String bookingId}) async {
    emit(const BookingLoading());
    final result = await _repo.cancelBooking(bookingId: bookingId);
    result.fold(
      (f) => emit(BookingError(f.message)),
      (_) => emit(const BookingCancelled()),
    );
  }
}

/// Manages saved landmark CRUD state directly with [PassengerRepository].
@injectable
class LandmarkCubit extends Cubit<LandmarkState> {
  LandmarkCubit({
    required PassengerRepository passengerRepository,
  })  : _repo = passengerRepository,
        super(const LandmarkInitial());

  final PassengerRepository _repo;

  Future<void> loadLandmarks() async {
    emit(const LandmarkLoading());
    final result = await _repo.getSavedLandmarks();
    result.fold(
      (f) => emit(LandmarkError(f.message)),
      (landmarks) => emit(LandmarksLoaded(landmarks)),
    );
  }

  Future<void> saveLandmark(LandmarkModel landmark) async {
    final result = await _repo.saveLandmark(landmark);
    result.fold(
      (f) => emit(LandmarkError(f.message)),
      (saved) => emit(LandmarkSaved(saved)),
    );
  }

  Future<void> deleteLandmark(String landmarkId) async {
    final result = await _repo.deleteLandmark(landmarkId: landmarkId);
    result.fold(
      (f) => emit(LandmarkError(f.message)),
      (_) => emit(LandmarkDeleted(landmarkId)),
    );
  }
}
