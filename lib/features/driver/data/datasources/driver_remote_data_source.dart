import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/driver_models.dart';

abstract class DriverRemoteDataSource {
  Future<DriverStatusModel> getDriverStatus();
  Future<DriverStatusModel> updateDriverStatus(DriverStatus status);
  Future<ActiveRouteModel?> getActiveRoute();
  Future<bool> updateSeatAvailability({
    required String routeId,
    required int seatNumber,
    required bool isOccupied,
  });
  Future<EarningsModel> getEarnings({String period = 'today'});
}

@LazySingleton(as: DriverRemoteDataSource)
class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  const DriverRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<DriverStatusModel> getDriverStatus() async {
    try {
      final r = await _dio.get(ApiEndpoints.driverStatus);
      return DriverStatusModel.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<DriverStatusModel> updateDriverStatus(DriverStatus status) async {
    try {
      final r = await _dio.patch(
        ApiEndpoints.driverStatus,
        data: {'status': status == DriverStatus.onTrip ? 'on_trip' : status.name},
      );
      return DriverStatusModel.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<ActiveRouteModel?> getActiveRoute() async {
    try {
      final r = await _dio.get(ApiEndpoints.driverActiveRoute);
      if (r.data == null) return null;
      return ActiveRouteModel.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw e.toAppException();
    }
  }

  @override
  Future<bool> updateSeatAvailability({
    required String routeId,
    required int seatNumber,
    required bool isOccupied,
  }) async {
    try {
      await _dio.patch(ApiEndpoints.updateSeats, data: {
        'route_id': routeId,
        'seat_number': seatNumber,
        'is_occupied': isOccupied,
      });
      return true;
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<EarningsModel> getEarnings({String period = 'today'}) async {
    try {
      final r = await _dio.get(ApiEndpoints.driverEarningsByPeriod(period));
      return EarningsModel.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }
}
