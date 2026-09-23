import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/landmark_entity.dart';
import '../../domain/usecases/book_seat_usecase.dart';
import '../../domain/usecases/get_available_routes_usecase.dart';
import '../../domain/usecases/landmark_usecases.dart';
import '../../domain/repositories/passenger_repository.dart';
import 'passenger_states.dart';

/// Manages seat booking and route browsing state.
@injectable
class BookingCubit extends Cubit<BookingState> {
  BookingCubit({
    required GetAvailableRoutesUseCase getAvailableRoutes,
    required BookSeatUseCase bookSeat,
    required PassengerRepository passengerRepository,
  })  : _getRoutes = getAvailableRoutes,
        _bookSeat = bookSeat,
        _repo = passengerRepository,
        super(const BookingInitial());

  final GetAvailableRoutesUseCase _getRoutes;
  final BookSeatUseCase _bookSeat;
  final PassengerRepository _repo;

  Future<void> loadRoutes({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    emit(const BookingLoading());
    final result = await _getRoutes(
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
    final result = await _bookSeat(routeId: routeId, seatNumber: seatNumber);
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

/// Manages saved landmark CRUD state.
@injectable
class LandmarkCubit extends Cubit<LandmarkState> {
  LandmarkCubit({
    required GetSavedLandmarksUseCase getSavedLandmarks,
    required SaveLandmarkUseCase saveLandmark,
    required DeleteLandmarkUseCase deleteLandmark,
  })  : _get = getSavedLandmarks,
        _save = saveLandmark,
        _delete = deleteLandmark,
        super(const LandmarkInitial());

  final GetSavedLandmarksUseCase _get;
  final SaveLandmarkUseCase _save;
  final DeleteLandmarkUseCase _delete;

  Future<void> loadLandmarks() async {
    emit(const LandmarkLoading());
    final result = await _get();
    result.fold(
      (f) => emit(LandmarkError(f.message)),
      (landmarks) => emit(LandmarksLoaded(landmarks)),
    );
  }

  Future<void> saveLandmark(LandmarkEntity landmark) async {
    final result = await _save(landmark);
    result.fold(
      (f) => emit(LandmarkError(f.message)),
      (saved) => emit(LandmarkSaved(saved)),
    );
  }

  Future<void> deleteLandmark(String landmarkId) async {
    final result = await _delete(landmarkId: landmarkId);
    result.fold(
      (f) => emit(LandmarkError(f.message)),
      (_) => emit(LandmarkDeleted(landmarkId)),
    );
  }
}
