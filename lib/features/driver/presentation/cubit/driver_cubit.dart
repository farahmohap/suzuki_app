import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/driver_models.dart';
import '../../data/repositories/driver_repository.dart';
import 'driver_state.dart';

/// Orchestrates all driver-side state directly with [DriverRepository].
@injectable
class DriverCubit extends Cubit<DriverState> {
  DriverCubit({
    required DriverRepository driverRepository,
  })  : _repo = driverRepository,
        super(const DriverInitial());

  final DriverRepository _repo;

  Future<void> goOnline() => _toggleStatus(DriverStatus.online);
  Future<void> goOffline() => _toggleStatus(DriverStatus.offline);

  Future<void> _toggleStatus(DriverStatus status) async {
    emit(const DriverLoading());
    final result = await _repo.updateDriverStatus(status);
    result.fold(
      (f) => emit(DriverError(f.message)),
      (s) => emit(DriverStatusUpdated(s)),
    );
  }

  Future<void> loadActiveRoute() async {
    emit(const DriverLoading());
    final result = await _repo.getActiveRoute();
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
    final result = await _repo.updateSeatAvailability(
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
    final result = await _repo.getEarnings(period: period);
    result.fold(
      (f) => emit(DriverError(f.message)),
      (earnings) => emit(EarningsLoaded(earnings)),
    );
  }
}
