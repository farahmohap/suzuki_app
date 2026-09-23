import 'package:equatable/equatable.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

/// Driver online/offline status.
enum DriverStatus {
  online,
  offline,
  onTrip;

  String get label {
    switch (this) {
      case online:
        return 'متاح';
      case offline:
        return 'غير متاح';
      case onTrip:
        return 'في رحلة';
    }
  }

  static DriverStatus fromString(String? s) {
    switch (s) {
      case 'online':
        return DriverStatus.online;
      case 'on_trip':
      case 'onTrip':
        return DriverStatus.onTrip;
      default:
        return DriverStatus.offline;
    }
  }
}

// ── DriverStatusModel ─────────────────────────────────────────────────────

class DriverStatusModel extends Equatable {
  const DriverStatusModel({
    required this.driverId,
    required this.status,
    required this.lastUpdated,
  });

  final String driverId;
  final DriverStatus status;
  final DateTime lastUpdated;

  bool get isOnline => status == DriverStatus.online;
  bool get isOnTrip => status == DriverStatus.onTrip;

  factory DriverStatusModel.fromJson(Map<String, dynamic> json) {
    return DriverStatusModel(
      driverId: json['driver_id'] as String? ?? json['id'] as String? ?? '',
      status: DriverStatus.fromString(json['status'] as String?),
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

  @override
  List<Object?> get props => [driverId, status, lastUpdated];
}

// ── VehicleSeatModel ──────────────────────────────────────────────────────

class VehicleSeatModel extends Equatable {
  const VehicleSeatModel({
    required this.seatNumber,
    required this.isOccupied,
    this.passengerId,
    this.passengerName,
  });

  final int seatNumber;
  final bool isOccupied;
  final String? passengerId;
  final String? passengerName;

  bool get isDriver => seatNumber == 1;
  bool get isAvailable => !isOccupied && !isDriver;

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

  VehicleSeatModel copyWith({
    int? seatNumber,
    bool? isOccupied,
    String? passengerId,
    String? passengerName,
  }) {
    return VehicleSeatModel(
      seatNumber: seatNumber ?? this.seatNumber,
      isOccupied: isOccupied ?? this.isOccupied,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
    );
  }

  @override
  List<Object?> get props => [seatNumber, isOccupied, passengerId, passengerName];
}

// ── ActiveRouteModel ──────────────────────────────────────────────────────

class ActiveRouteModel extends Equatable {
  const ActiveRouteModel({
    required this.routeId,
    required this.originName,
    required this.destinationName,
    required this.seats,
    required this.departureTime,
    this.estimatedArrival,
    this.fare,
  });

  final String routeId;
  final String originName;
  final String destinationName;
  final List<VehicleSeatModel> seats;
  final DateTime departureTime;
  final DateTime? estimatedArrival;
  final double? fare;

  int get occupiedCount => seats.where((s) => s.isOccupied && !s.isDriver).length;
  int get totalPassengerSeats => seats.where((s) => !s.isDriver).length;
  int get availableCount => totalPassengerSeats - occupiedCount;

  factory ActiveRouteModel.fromJson(Map<String, dynamic> json) {
    final seatList = (json['seats'] as List<dynamic>? ?? [])
        .map((s) => VehicleSeatModel.fromJson(s as Map<String, dynamic>))
        .toList();
    return ActiveRouteModel(
      routeId: json['route_id'] as String? ?? json['id'] as String? ?? '',
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

  Map<String, dynamic> toJson() => {
        'route_id': routeId,
        'origin_name': originName,
        'destination_name': destinationName,
        'seats': seats.map((s) => s.toJson()).toList(),
        'departure_time': departureTime.toIso8601String(),
        'estimated_arrival': estimatedArrival?.toIso8601String(),
        'fare': fare,
      };

  @override
  List<Object?> get props => [
        routeId,
        originName,
        destinationName,
        seats,
        departureTime,
      ];
}

// ── EarningsModel ─────────────────────────────────────────────────────────

class DailyEarning extends Equatable {
  const DailyEarning({
    required this.date,
    required this.amount,
    required this.trips,
  });

  final DateTime date;
  final double amount;
  final int trips;

  factory DailyEarning.fromJson(Map<String, dynamic> json) {
    return DailyEarning(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      trips: json['trips'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'amount': amount,
        'trips': trips,
      };

  @override
  List<Object?> get props => [date, amount, trips];
}

class EarningsModel extends Equatable {
  const EarningsModel({
    required this.driverId,
    required this.totalEarnings,
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.totalTrips,
    required this.todayTrips,
    this.dailyBreakdown = const [],
  });

  final String driverId;
  final double totalEarnings;
  final double todayEarnings;
  final double weeklyEarnings;
  final int totalTrips;
  final int todayTrips;
  final List<DailyEarning> dailyBreakdown;

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    final breakdown = (json['daily_breakdown'] as List<dynamic>? ?? [])
        .map((d) => DailyEarning.fromJson(d as Map<String, dynamic>))
        .toList();
    return EarningsModel(
      driverId: json['driver_id'] as String? ?? json['id'] as String? ?? '',
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0,
      todayEarnings: (json['today_earnings'] as num?)?.toDouble() ?? 0,
      weeklyEarnings: (json['weekly_earnings'] as num?)?.toDouble() ?? 0,
      totalTrips: json['total_trips'] as int? ?? 0,
      todayTrips: json['today_trips'] as int? ?? 0,
      dailyBreakdown: breakdown,
    );
  }

  Map<String, dynamic> toJson() => {
        'driver_id': driverId,
        'total_earnings': totalEarnings,
        'today_earnings': todayEarnings,
        'weekly_earnings': weeklyEarnings,
        'total_trips': totalTrips,
        'today_trips': todayTrips,
        'daily_breakdown': dailyBreakdown.map((d) => d.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        driverId,
        totalEarnings,
        todayEarnings,
        weeklyEarnings,
        totalTrips,
        todayTrips,
      ];
}
