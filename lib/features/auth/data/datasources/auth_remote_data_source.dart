import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_model.dart';

/// Contract for remote auth data operations.
abstract class AuthRemoteDataSource {
  Future<AuthModel> login({required String phone, required String password});
  Future<AuthModel> register({
    required String phone,
    required String password,
    required String fullName,
    required String role,
  });
  Future<AuthModel> verifyOtp({required String phone, required String otp});
  Future<bool> resendOtp({required String phone});
  Future<bool> logout({required String token});
}

/// Dio-backed implementation of [AuthRemoteDataSource].
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthModel> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'phone': phone, 'password': password},
      );
      _assertSuccess(response);
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<AuthModel> register({
    required String phone,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {
          'phone': phone,
          'password': password,
          'full_name': fullName,
          'role': role,
        },
      );
      _assertSuccess(response);
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<AuthModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyOtp,
        data: {'phone': phone, 'otp': otp},
      );
      _assertSuccess(response);
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<bool> resendOtp({required String phone}) async {
    try {
      await _dio.post(ApiEndpoints.resendOtp, data: {'phone': phone});
      return true;
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<bool> logout({required String token}) async {
    try {
      await _dio.post(ApiEndpoints.logout);
      return true;
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  void _assertSuccess(Response response) {
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      final msg = (response.data as Map<String, dynamic>?)?['message']
              as String? ??
          'خطأ في الخادم';
      throw ServerException(message: msg, statusCode: status);
    }
  }
}
