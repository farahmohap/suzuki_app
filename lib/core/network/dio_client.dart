import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../error/exceptions.dart';
import 'api_endpoints.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';

/// Configured [Dio] singleton factory for سوزوكي API.
///
/// Attaches:
///   • [AuthInterceptor]    — injects Bearer token, handles 401 refresh
///   • [LoggingInterceptor] — dev-only pretty request/response logs
class DioClient {
  DioClient._();

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _build();
    return _instance!;
  }

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Accept-Language': 'ar',
        },
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(dio),
      if (kDebugMode) LoggingInterceptor(),
    ]);

    return dio;
  }

  /// Resets the singleton — useful in tests.
  @visibleForTesting
  static void reset() => _instance = null;
}

/// Extension on [DioException] → [AppException] mapping.
extension DioExceptionMapper on DioException {
  AppException toAppException() {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        final status = response?.statusCode;
        final data = response?.data;
        final msg = data is Map ? (data['message'] ?? data['error']) : null;

        if (status == 401) {
          return const AuthException();
        }
        return ServerException(
          message: msg?.toString() ?? 'خطأ في الخادم',
          statusCode: status,
          code: 'HTTP_$status',
        );

      case DioExceptionType.cancel:
        return const NetworkException(message: 'تم إلغاء الطلب');

      default:
        return ServerException(
          message: message ?? 'خطأ غير متوقع',
          code: 'DIO_UNKNOWN',
        );
    }
  }
}
