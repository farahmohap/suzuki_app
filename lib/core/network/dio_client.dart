import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../error/exceptions.dart';
import '../session/session_events.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';

/// Builds THE app Dio (registered once in DI — see core/di/injection.dart).
///
/// Interceptors: [AuthInterceptor] (+ [LoggingInterceptor] in debug).
Dio buildApiDio({
  required TokenStorage tokens,
  required SessionEvents session,
}) {
  final options = BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': 'ar',
    },
    responseType: ResponseType.json,
  );

  final api = Dio(options);
  final refreshDio = Dio(options.copyWith()); // no interceptors on purpose

  api.interceptors.add(
    AuthInterceptor(
      apiDio: api,
      refreshDio: refreshDio,
      tokens: tokens,
      session: session,
    ),
  );
  if (kDebugMode) api.interceptors.add(LoggingInterceptor());
  return api;
}

/// Maps [DioException] to a typed [AppException].
///
/// Understands the backend error envelope:
/// `{ "error": { "code": "...", "message_ar": "...", "fields": {...} } }`
extension DioExceptionMapper on DioException {
  AppException toAppException() {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException(
          message: 'انتهت مهلة الاتصال، حاول مرة أخرى',
          code: 'TIMEOUT',
        );
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.cancel:
        return const NetworkException(message: 'تم إلغاء الطلب');
      case DioExceptionType.badResponse:
        return _fromResponse();
      default:
        return ServerException(
          message: 'خطأ غير متوقع',
          code: 'DIO_UNKNOWN',
        );
    }
  }

  AppException _fromResponse() {
    final status = response?.statusCode;
    final data = response?.data;

    String? code;
    String? message;
    Map<String, String>? fields;

    if (data is Map) {
      final err = data['error'];
      if (err is Map) {
        code = err['code']?.toString();
        message = (err['message_ar'] ?? err['message'])?.toString();
        final f = err['fields'];
        if (f is Map) {
          fields = f.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
      } else {
        message = (data['message'] ?? data['error'])?.toString();
      }
    }

    if (status == 408 || status == 504) {
      return NetworkException(
        message: message ?? 'انتهت مهلة الاتصال، حاول مرة أخرى',
        code: code ?? 'TIMEOUT',
      );
    }
    if (status == 401) {
      return AuthException(
        message: message ?? 'غير مصرح لك بالوصول',
        code: code ?? 'AUTH_ERROR',
      );
    }
    return ServerException(
      message: message ?? 'خطأ في الخادم',
      statusCode: status,
      code: code ?? 'HTTP_$status',
      fields: fields,
    );
  }
}
