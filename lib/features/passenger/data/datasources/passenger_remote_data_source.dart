import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/passenger_models.dart';

abstract class PassengerRemoteDataSource {
  Future<List<RouteModel>> getAvailableRoutes({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  });
  Future<SeatBookingModel> bookSeat({
    required String routeId,
    required int seatNumber,
  });
  Future<SeatBookingModel?> getActiveBooking();
  Future<bool> cancelBooking({required String bookingId});
  Future<List<LandmarkModel>> getLandmarks();
  Future<LandmarkModel> saveLandmark(LandmarkModel landmark);
  Future<bool> deleteLandmark({required String landmarkId});
}

@LazySingleton(as: PassengerRemoteDataSource)
class PassengerRemoteDataSourceImpl implements PassengerRemoteDataSource {
  PassengerRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<RouteModel>> getAvailableRoutes({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.availableRoutes,
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radius': radiusKm,
        },
      );
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<SeatBookingModel> bookSeat({
    required String routeId,
    required int seatNumber,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.bookSeat,
        data: {'route_id': routeId, 'seat_number': seatNumber},
      );
      return SeatBookingModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<SeatBookingModel?> getActiveBooking() async {
    try {
      final response = await _dio.get(ApiEndpoints.activeBooking);
      if (response.data == null) return null;
      return SeatBookingModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw e.toAppException();
    }
  }

  @override
  Future<bool> cancelBooking({required String bookingId}) async {
    try {
      await _dio.post(
        ApiEndpoints.cancelBooking,
        data: {'booking_id': bookingId},
      );
      return true;
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<List<LandmarkModel>> getLandmarks() async {
    try {
      final response = await _dio.get(ApiEndpoints.landmarks);
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => LandmarkModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<LandmarkModel> saveLandmark(LandmarkModel landmark) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.landmarks,
        data: landmark.toJson(),
      );
      return LandmarkModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<bool> deleteLandmark({required String landmarkId}) async {
    try {
      await _dio.delete(ApiEndpoints.landmarkById(landmarkId));
      return true;
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }
}
