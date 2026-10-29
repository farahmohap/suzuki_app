import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_model.dart';

/// Contract for remote auth operations (OTP-only login).
abstract class AuthRemoteDataSource {
  Future<void> requestOtp({required String phone, required UserRole role});
  Future<AuthSession> verifyOtp({
    required String phone,
    required String code,
    required String deviceId,
  });
  Future<AuthModel> getMe();
  Future<void> logout({required String refreshToken});
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static final _noAuth = Options(extra: {kSkipAuth: true});

  @override
  Future<void> requestOtp({
    required String phone,
    required UserRole role,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.otpRequest,
        data: {'phone': phone, 'role': role.apiValue},
        options: _noAuth,
      );
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<AuthSession> verifyOtp({
    required String phone,
    required String code,
    required String deviceId,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.otpVerify,
        data: {'phone': phone, 'code': code, 'device_id': deviceId},
        options: _noAuth,
      );
      return AuthSession.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<AuthModel> getMe() async {
    try {
      final res = await _dio.get(ApiEndpoints.me);
      return AuthModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await _dio.post(
        ApiEndpoints.logout,
        data: {'refresh_token': refreshToken},
      );
    } on DioException catch (e) {
      throw e.toAppException();
    }
  }
}
