import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/driver_entities.dart';
import '../../domain/usecases/driver_usecases.dart';
import 'driver_state.dart';

/// Orchestrates all driver-side state: online/offline toggle,
/// active route, seat management, and earnings.
@injectable
class DriverCubit extends Cubit<DriverState> {
  DriverCubit({
    required UpdateDriverStatusUseCase updateDriverStatus,
    required GetActiveRouteUseCase getActiveRoute,
    required UpdateSeatAvailabilityUseCase updateSeatAvailability,
    required GetEarningsUseCase getEarnings,
  })  : _updateStatus = updateDriverStatus,
        _getRoute = getActiveRoute,
        _updateSeat = updateSeatAvailability,
        _getEarnings = getEarnings,
        super(const DriverInitial());

  final UpdateDriverStatusUseCase _updateStatus;
  final GetActiveRouteUseCase _getRoute;
  final UpdateSeatAvailabilityUseCase _updateSeat;
  final GetEarningsUseCase _getEarnings;

  Future<void> goOnline() => _toggleStatus(DriverStatus.online);
  Future<void> goOffline() => _toggleStatus(DriverStatus.offline);

  Future<void> _toggleStatus(DriverStatus status) async {
    emit(const DriverLoading());
    final result = await _updateStatus(status);
    result.fold(
      (f) => emit(DriverError(f.message)),
      (s) => emit(DriverStatusUpdated(s)),
    );
  }

  Future<void> loadActiveRoute() async {
    emit(const DriverLoading());
    final result = await _getRoute();
    result.fold(
      (f) => emit(DriverError(f.message)),
      (route) => emit(ActiveRouteLoaded(route)),
    );
  }

  Future<void> toggleSeat({
    required String routeId,
    required int seatNumber,
    required bool isOccupied,
  }) async {
    final result = await _updateSeat(
      routeId: routeId,
      seatNumber: seatNumber,
      isOccupied: isOccupied,
    );
    result.fold(
      (f) => emit(DriverError(f.message)),
      (_) => emit(SeatUpdated(seatNumber: seatNumber, isOccupied: isOccupied)),
    );
  }

  Future<void> loadEarnings({String period = 'today'}) async {
    emit(const DriverLoading());
    final result = await _getEarnings(period: period);
    result.fold(
      (f) => emit(DriverError(f.message)),
      (earnings) => emit(EarningsLoaded(earnings)),
    );
  }
}
