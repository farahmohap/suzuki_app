import 'package:latlong2/latlong.dart';
import '../../domain/entities/seat_booking_entity.dart';
import '../../domain/entities/landmark_entity.dart';
import '../../domain/entities/route_entity.dart';

// ── RouteModel ───────────────────────────────────────────────────────────────

class RouteModel extends RouteEntity {
  const RouteModel({
    required super.routeId,
    required super.name,
    required super.origin,
    required super.destination,
    required super.originName,
    required super.destinationName,
    required super.availableSeats,
    required super.totalSeats,
    required super.fare,
    required super.estimatedDuration,
    required super.departureTime,
    super.waypoints,
    super.driverName,
    super.vehiclePlate,
    super.distanceKm,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final orig = json['origin'] as Map<String, dynamic>;
    final dest = json['destination'] as Map<String, dynamic>;
    return RouteModel(
      routeId: json['route_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      origin: LatLng(
        (orig['lat'] as num).toDouble(),
        (orig['lng'] as num).toDouble(),
      ),
      destination: LatLng(
        (dest['lat'] as num).toDouble(),
        (dest['lng'] as num).toDouble(),
      ),
      originName: json['origin_name'] as String? ?? '',
      destinationName: json['destination_name'] as String? ?? '',
      availableSeats: json['available_seats'] as int? ?? 0,
      totalSeats: json['total_seats'] as int? ?? 14,
      fare: (json['fare'] as num?)?.toDouble() ?? 0.0,
      estimatedDuration:
          Duration(minutes: json['duration_minutes'] as int? ?? 0),
      departureTime: json['departure_time'] != null
          ? DateTime.parse(json['departure_time'] as String)
          : DateTime.now(),
      driverName: json['driver_name'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'route_id': routeId,
        'name': name,
        'origin': {'lat': origin.latitude, 'lng': origin.longitude},
        'destination': {
          'lat': destination.latitude,
          'lng': destination.longitude
        },
        'origin_name': originName,
        'destination_name': destinationName,
        'available_seats': availableSeats,
        'total_seats': totalSeats,
        'fare': fare,
        'duration_minutes': estimatedDuration.inMinutes,
        'departure_time': departureTime.toIso8601String(),
        'driver_name': driverName,
        'vehicle_plate': vehiclePlate,
        'distance_km': distanceKm,
      };
}

// ── SeatBookingModel ─────────────────────────────────────────────────────────

class SeatBookingModel extends SeatBookingEntity {
  const SeatBookingModel({
    required super.bookingId,
    required super.routeId,
    required super.passengerId,
    required super.seatNumber,
    required super.status,
    required super.bookedAt,
    super.fare,
    super.estimatedArrival,
    super.driverName,
    super.vehiclePlate,
    super.currentDriverLocation,
  });

  factory SeatBookingModel.fromJson(Map<String, dynamic> json) {
    LatLng? driverLoc;
    final loc = json['driver_location'] as Map<String, dynamic>?;
    if (loc != null) {
      driverLoc = LatLng(
        (loc['lat'] as num).toDouble(),
        (loc['lng'] as num).toDouble(),
      );
    }
    return SeatBookingModel(
      bookingId: json['booking_id'] as String? ?? json['id'] as String? ?? '',
      routeId: json['route_id'] as String? ?? '',
      passengerId: json['passenger_id'] as String? ?? '',
      seatNumber: json['seat_number'] as int? ?? 0,
      status: _parseStatus(json['status'] as String?),
      bookedAt: json['booked_at'] != null
          ? DateTime.parse(json['booked_at'] as String)
          : DateTime.now(),
      fare: (json['fare'] as num?)?.toDouble(),
      estimatedArrival: json['estimated_arrival'] != null
          ? DateTime.parse(json['estimated_arrival'] as String)
          : null,
      driverName: json['driver_name'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      currentDriverLocation: driverLoc,
    );
  }

  static BookingStatus _parseStatus(String? s) {
    switch (s) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'in_progress':
        return BookingStatus.inProgress;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}

// ── LandmarkModel ─────────────────────────────────────────────────────────────

class LandmarkModel extends LandmarkEntity {
  const LandmarkModel({
    required super.id,
    required super.name,
    required super.location,
    super.address,
    super.type,
  });

  factory LandmarkModel.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>;
    return LandmarkModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: LatLng(
        (loc['lat'] as num).toDouble(),
        (loc['lng'] as num).toDouble(),
      ),
      address: json['address'] as String?,
      type: _parseType(json['type'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': {
          'lat': location.latitude,
          'lng': location.longitude,
        },
        'address': address,
        'type': type.name,
      };

  factory LandmarkModel.fromEntity(LandmarkEntity entity) => LandmarkModel(
        id: entity.id,
        name: entity.name,
        location: entity.location,
        address: entity.address,
        type: entity.type,
      );

  static LandmarkType _parseType(String? s) {
    switch (s) {
      case 'home':
        return LandmarkType.home;
      case 'work':
        return LandmarkType.work;
      default:
        return LandmarkType.custom;
    }
  }
}
