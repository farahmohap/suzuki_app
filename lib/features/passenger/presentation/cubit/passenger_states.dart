import 'package:equatable/equatable.dart';
import '../../data/models/passenger_models.dart';

// ── Booking State ────────────────────────────────────────────────────────────

sealed class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

final class BookingInitial extends BookingState {
  const BookingInitial();
}

final class BookingLoading extends BookingState {
  const BookingLoading();
}

final class RoutesLoaded extends BookingState {
  const RoutesLoaded(this.routes);
  final List<RouteModel> routes;
  @override
  List<Object?> get props => [routes];
}

final class SeatBooked extends BookingState {
  const SeatBooked(this.booking);
  final SeatBookingModel booking;
  @override
  List<Object?> get props => [booking];
}

final class ActiveBookingLoaded extends BookingState {
  const ActiveBookingLoaded(this.booking);
  final SeatBookingModel? booking;
  @override
  List<Object?> get props => [booking];
}

final class BookingCancelled extends BookingState {
  const BookingCancelled();
}

final class BookingError extends BookingState {
  const BookingError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── Landmark State ───────────────────────────────────────────────────────────

sealed class LandmarkState extends Equatable {
  const LandmarkState();
  @override
  List<Object?> get props => [];
}

final class LandmarkInitial extends LandmarkState {
  const LandmarkInitial();
}

final class LandmarkLoading extends LandmarkState {
  const LandmarkLoading();
}

final class LandmarksLoaded extends LandmarkState {
  const LandmarksLoaded(this.landmarks);
  final List<LandmarkModel> landmarks;
  @override
  List<Object?> get props => [landmarks];
}

final class LandmarkSaved extends LandmarkState {
  const LandmarkSaved(this.landmark);
  final LandmarkModel landmark;
  @override
  List<Object?> get props => [landmark];
}

final class LandmarkDeleted extends LandmarkState {
  const LandmarkDeleted(this.landmarkId);
  final String landmarkId;
  @override
  List<Object?> get props => [landmarkId];
}

final class LandmarkError extends LandmarkState {
  const LandmarkError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
