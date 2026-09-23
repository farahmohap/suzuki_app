import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

/// Lifecycle status for a seat reservation.
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
        return 'في الطريق';
      case completed:
        return 'مكتمل';
      case cancelled:
        return 'ملغي';
    }
  }

  static BookingStatus fromString(String? s) {
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

/// Category of a passenger's saved location.
enum LandmarkType {
  home,
  work,
  custom;

  String get label {
    switch (this) {
      case home:
        return 'المنزل';
      case work:
        return 'العمل';
      case custom:
        return 'مخصص';
    }
  }

  String get iconEmoji {
    switch (this) {
      case home:
        return '🏠';
      case work:
        return '💼';
      case custom:
        return '📍';
    }
  }

  static LandmarkType fromString(String? s) {
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

// ── RouteModel ───────────────────────────────────────────────────────────────

class RouteModel extends Equatable {
  const RouteModel({
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
  double get occupancyPercent =>
      totalSeats > 0 ? (totalSeats - availableSeats) / totalSeats : 0.0;

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final orig = json['origin'] as Map<String, dynamic>? ?? {};
    final dest = json['destination'] as Map<String, dynamic>? ?? {};
    final waypointList = (json['waypoints'] as List<dynamic>? ?? [])
        .map((w) => LatLng(
              ((w as Map)['lat'] as num).toDouble(),
              (w['lng'] as num).toDouble(),
            ))
        .toList();

    return RouteModel(
      routeId: json['route_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      origin: LatLng(
        (orig['lat'] as num?)?.toDouble() ?? 0.0,
        (orig['lng'] as num?)?.toDouble() ?? 0.0,
      ),
      destination: LatLng(
        (dest['lat'] as num?)?.toDouble() ?? 0.0,
        (dest['lng'] as num?)?.toDouble() ?? 0.0,
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
      waypoints: waypointList,
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
        'waypoints': waypoints
            .map((w) => {'lat': w.latitude, 'lng': w.longitude})
            .toList(),
        'driver_name': driverName,
        'vehicle_plate': vehiclePlate,
        'distance_km': distanceKm,
      };

  RouteModel copyWith({
    String? routeId,
    String? name,
    LatLng? origin,
    LatLng? destination,
    String? originName,
    String? destinationName,
    int? availableSeats,
    int? totalSeats,
    double? fare,
    Duration? estimatedDuration,
    DateTime? departureTime,
    List<LatLng>? waypoints,
    String? driverName,
    String? vehiclePlate,
    double? distanceKm,
  }) {
    return RouteModel(
      routeId: routeId ?? this.routeId,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      originName: originName ?? this.originName,
      destinationName: destinationName ?? this.destinationName,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      fare: fare ?? this.fare,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      departureTime: departureTime ?? this.departureTime,
      waypoints: waypoints ?? this.waypoints,
      driverName: driverName ?? this.driverName,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

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

// ── SeatBookingModel ─────────────────────────────────────────────────────────

class SeatBookingModel extends Equatable {
  const SeatBookingModel({
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
      status: BookingStatus.fromString(json['status'] as String?),
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

  Map<String, dynamic> toJson() => {
        'booking_id': bookingId,
        'route_id': routeId,
        'passenger_id': passengerId,
        'seat_number': seatNumber,
        'status': status.name,
        'booked_at': bookedAt.toIso8601String(),
        'fare': fare,
        'estimated_arrival': estimatedArrival?.toIso8601String(),
        'driver_name': driverName,
        'vehicle_plate': vehiclePlate,
        if (currentDriverLocation != null)
          'driver_location': {
            'lat': currentDriverLocation!.latitude,
            'lng': currentDriverLocation!.longitude,
          },
      };

  @override
  List<Object?> get props => [
        bookingId,
        routeId,
        passengerId,
        seatNumber,
        status,
        bookedAt,
      ];
}

// ── LandmarkModel ─────────────────────────────────────────────────────────────

class LandmarkModel extends Equatable {
  const LandmarkModel({
    required this.id,
    required this.name,
    required this.location,
    this.address,
    this.type = LandmarkType.custom,
  });

  final String id;
  final String name;
  final LatLng location;
  final String? address;
  final LandmarkType type;

  factory LandmarkModel.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>? ?? {};
    return LandmarkModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: LatLng(
        (loc['lat'] as num?)?.toDouble() ?? 0.0,
        (loc['lng'] as num?)?.toDouble() ?? 0.0,
      ),
      address: json['address'] as String?,
      type: LandmarkType.fromString(json['type'] as String?),
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

  @override
  List<Object?> get props => [id, name, location, address, type];
}
