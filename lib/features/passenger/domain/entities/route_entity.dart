import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// A Suzuki transit route available for booking.
class RouteEntity extends Equatable {
  const RouteEntity({
    required this.routeId,
    required this.name,
    required this.origin,
    required this.destination,
    required this.originName,
    required this.destinationName,
    required this.availableSeats,
    required this.totalSeats,
    required this.fare,
    required this.estimatedDuration,
    required this.departureTime,
    this.waypoints = const [],
    this.driverName,
    this.vehiclePlate,
    this.distanceKm,
  });

  final String routeId;
  final String name;
  final LatLng origin;
  final LatLng destination;
  final String originName;
  final String destinationName;
  final int availableSeats;
  final int totalSeats;
  final double fare;
  final Duration estimatedDuration;
  final DateTime departureTime;
  final List<LatLng> waypoints;
  final String? driverName;
  final String? vehiclePlate;
  final double? distanceKm;

  bool get hasAvailableSeats => availableSeats > 0;
  int get occupiedSeats => totalSeats - availableSeats;

  @override
  List<Object?> get props => [
        routeId,
        name,
        origin,
        destination,
        originName,
        destinationName,
        availableSeats,
        totalSeats,
        fare,
        estimatedDuration,
        departureTime,
      ];
}
