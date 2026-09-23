import 'package:equatable/equatable.dart';

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
}

class DriverStatusEntity extends Equatable {
  const DriverStatusEntity({
    required this.driverId,
    required this.status,
    required this.lastUpdated,
  });

  final String driverId;
  final DriverStatus status;
  final DateTime lastUpdated;

  bool get isOnline => status == DriverStatus.online;
  bool get isOnTrip => status == DriverStatus.onTrip;

  @override
  List<Object?> get props => [driverId, status, lastUpdated];
}

/// State of a single vehicle seat.
class VehicleSeatEntity extends Equatable {
  const VehicleSeatEntity({
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

  VehicleSeatEntity copyWith({bool? isOccupied, String? passengerId, String? passengerName}) {
    return VehicleSeatEntity(
      seatNumber: seatNumber,
      isOccupied: isOccupied ?? this.isOccupied,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
    );
  }

  @override
  List<Object?> get props => [seatNumber, isOccupied, passengerId, passengerName];
}

/// A currently active route managed by the driver.
class ActiveRouteEntity extends Equatable {
  const ActiveRouteEntity({
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
  final List<VehicleSeatEntity> seats;
  final DateTime departureTime;
  final DateTime? estimatedArrival;
  final double? fare;

  int get occupiedCount => seats.where((s) => s.isOccupied && !s.isDriver).length;
  int get totalPassengerSeats => seats.where((s) => !s.isDriver).length;
  int get availableCount => totalPassengerSeats - occupiedCount;

  @override
  List<Object?> get props => [routeId, originName, destinationName, seats, departureTime];
}

/// Driver earnings summary.
class EarningsEntity extends Equatable {
  const EarningsEntity({
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

class DailyEarning extends Equatable {
  const DailyEarning({
    required this.date,
    required this.amount,
    required this.trips,
  });

  final DateTime date;
  final double amount;
  final int trips;

  @override
  List<Object?> get props => [date, amount, trips];
}
