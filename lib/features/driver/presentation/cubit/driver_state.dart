import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_entities.dart';

sealed class DriverState extends Equatable {
  const DriverState();
  @override
  List<Object?> get props => [];
}

final class DriverInitial extends DriverState {
  const DriverInitial();
}

final class DriverLoading extends DriverState {
  const DriverLoading();
}

final class DriverStatusUpdated extends DriverState {
  const DriverStatusUpdated(this.status);
  final DriverStatusEntity status;
  @override
  List<Object?> get props => [status];
}

final class ActiveRouteLoaded extends DriverState {
  const ActiveRouteLoaded(this.route);
  final ActiveRouteEntity? route;
  @override
  List<Object?> get props => [route];
}

final class SeatUpdated extends DriverState {
  const SeatUpdated({required this.seatNumber, required this.isOccupied});
  final int seatNumber;
  final bool isOccupied;
  @override
  List<Object?> get props => [seatNumber, isOccupied];
}

final class EarningsLoaded extends DriverState {
  const EarningsLoaded(this.earnings);
  final EarningsEntity earnings;
  @override
  List<Object?> get props => [earnings];
}

final class DriverError extends DriverState {
  const DriverError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
