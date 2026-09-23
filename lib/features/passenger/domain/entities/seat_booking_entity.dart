import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// Represents a seat booking made by a passenger.
class SeatBookingEntity extends Equatable {
  const SeatBookingEntity({
    required this.bookingId,
    required this.routeId,
    required this.passengerId,
    required this.seatNumber,
    required this.status,
    required this.bookedAt,
    this.fare,
    this.estimatedArrival,
    this.driverName,
    this.vehiclePlate,
    this.currentDriverLocation,
  });

  final String bookingId;
  final String routeId;
  final String passengerId;
  final int seatNumber;
  final BookingStatus status;
  final DateTime bookedAt;
  final double? fare;
  final DateTime? estimatedArrival;
  final String? driverName;
  final String? vehiclePlate;
  final LatLng? currentDriverLocation;

  bool get isActive =>
      status == BookingStatus.confirmed || status == BookingStatus.inProgress;

  @override
  List<Object?> get props => [
        bookingId,
        routeId,
        passengerId,
        seatNumber,
        status,
        bookedAt,
        fare,
        estimatedArrival,
        driverName,
        vehiclePlate,
        currentDriverLocation,
      ];
}

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case pending:
        return 'قيد الانتظار';
      case confirmed:
        return 'مؤكد';
      case inProgress:
        return 'جارٍ التنفيذ';
      case completed:
        return 'مكتمل';
      case cancelled:
        return 'ملغى';
    }
  }
}
