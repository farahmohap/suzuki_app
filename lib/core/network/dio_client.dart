import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import '../error/exceptions.dart';
import '../session/session_events.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

/// Builds THE app Dio (registered once in DI — see core/di/injection.dart).
///
/// Interceptors: [AuthInterceptor] (+ [PrettyDioLogger] in debug).
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
  // Keep auth interception off to avoid refresh loops; debug logging is added below.
  final refreshDio = Dio(options.copyWith());

  api.interceptors.add(
    AuthInterceptor(
      apiDio: api,
      refreshDio: refreshDio,
      tokens: tokens,
      session: session,
    ),
  );
  if (kDebugMode) {
    api.interceptors.add(_prettyApiLogger());
    refreshDio.interceptors.add(_prettyApiLogger());
  }
  return api;
}

PrettyDioLogger _prettyApiLogger() => PrettyDioLogger(
  request: true,
  requestHeader: true,
  requestBody: true,
  responseHeader: true,
  // PrettyDioLogger prints bodies for both onResponse (2xx) and onError
  // (non-2xx), so backend error envelopes are visible as well.
  responseBody: true,
  error: true,
  compact: true,
  maxWidth: 120,
  logPrint: (object) => debugPrint(object.toString()),
);

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
        return ServerException(message: 'خطأ غير متوقع', code: 'DIO_UNKNOWN');
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
        final f = err['fields'] ?? err['details'];
        if (f is Map) {
          fields = f.map((k, v) {
            if (v is List && v.isNotEmpty) {
              return MapEntry(k.toString(), v.first.toString());
            }
            return MapEntry(k.toString(), v.toString());
          });
          if (fields != null &&
              fields.isNotEmpty &&
              (message == null ||
                  message == 'The given data was invalid.' ||
                  message.isEmpty)) {
            message = fields.values.first;
          }
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
