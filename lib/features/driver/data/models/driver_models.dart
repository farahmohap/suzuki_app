import '../../domain/entities/driver_entities.dart';

// ── DriverStatusModel ─────────────────────────────────────────────────────

class DriverStatusModel extends DriverStatusEntity {
  const DriverStatusModel({
    required super.driverId,
    required super.status,
    required super.lastUpdated,
  });

  factory DriverStatusModel.fromJson(Map<String, dynamic> json) {
    return DriverStatusModel(
      driverId: json['driver_id'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'driver_id': driverId,
        'status': status.name,
        'last_updated': lastUpdated.toIso8601String(),
      };

  static DriverStatus _parseStatus(String? s) {
    switch (s) {
      case 'online':
        return DriverStatus.online;
      case 'on_trip':
        return DriverStatus.onTrip;
      default:
        return DriverStatus.offline;
    }
  }
}

// ── VehicleSeatModel ──────────────────────────────────────────────────────

class VehicleSeatModel extends VehicleSeatEntity {
  const VehicleSeatModel({
    required super.seatNumber,
    required super.isOccupied,
    super.passengerId,
    super.passengerName,
  });

  factory VehicleSeatModel.fromJson(Map<String, dynamic> json) {
    return VehicleSeatModel(
      seatNumber: json['seat_number'] as int? ?? 0,
      isOccupied: json['is_occupied'] as bool? ?? false,
      passengerId: json['passenger_id'] as String?,
      passengerName: json['passenger_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'seat_number': seatNumber,
        'is_occupied': isOccupied,
        'passenger_id': passengerId,
        'passenger_name': passengerName,
      };
}

// ── ActiveRouteModel ──────────────────────────────────────────────────────

class ActiveRouteModel extends ActiveRouteEntity {
  const ActiveRouteModel({
    required super.routeId,
    required super.originName,
    required super.destinationName,
    required super.seats,
    required super.departureTime,
    super.estimatedArrival,
    super.fare,
  });

  factory ActiveRouteModel.fromJson(Map<String, dynamic> json) {
    final seatList = (json['seats'] as List<dynamic>? ?? [])
        .map((s) => VehicleSeatModel.fromJson(s as Map<String, dynamic>))
        .toList();
    return ActiveRouteModel(
      routeId: json['route_id'] as String? ?? '',
      originName: json['origin_name'] as String? ?? '',
      destinationName: json['destination_name'] as String? ?? '',
      seats: seatList,
      departureTime: json['departure_time'] != null
          ? DateTime.parse(json['departure_time'] as String)
          : DateTime.now(),
      estimatedArrival: json['estimated_arrival'] != null
          ? DateTime.parse(json['estimated_arrival'] as String)
          : null,
      fare: (json['fare'] as num?)?.toDouble(),
    );
  }
}

// ── EarningsModel ─────────────────────────────────────────────────────────

class EarningsModel extends EarningsEntity {
  const EarningsModel({
    required super.driverId,
    required super.totalEarnings,
    required super.todayEarnings,
    required super.weeklyEarnings,
    required super.totalTrips,
    required super.todayTrips,
    super.dailyBreakdown,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    final breakdown = (json['daily_breakdown'] as List<dynamic>? ?? [])
        .map((d) => DailyEarning(
              date: DateTime.parse((d as Map)['date'] as String),
              amount: ((d)['amount'] as num).toDouble(),
              trips: (d)['trips'] as int? ?? 0,
            ))
        .toList();
    return EarningsModel(
      driverId: json['driver_id'] as String? ?? '',
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0,
      todayEarnings: (json['today_earnings'] as num?)?.toDouble() ?? 0,
      weeklyEarnings: (json['weekly_earnings'] as num?)?.toDouble() ?? 0,
      totalTrips: json['total_trips'] as int? ?? 0,
      todayTrips: json['today_trips'] as int? ?? 0,
      dailyBreakdown: breakdown,
    );
  }
}
