import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Dev-only pretty-printer interceptor for Dio requests & responses.
/// Automatically stripped in release builds via [kDebugMode] check in [DioClient].
class LoggingInterceptor extends Interceptor {
  static const _separator = '────────────────────────────────────────────────────────────────';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('\n[$_tag] ▶ ${options.method} ${options.uri}');
    debugPrint('  Headers: ${_sanitize(options.headers)}');
    if (options.data != null) debugPrint('  Body: ${options.data}');
    debugPrint(_separator);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('\n[$_tag] ✅ ${response.statusCode} '
        '${response.requestOptions.method} ${response.requestOptions.uri}');
    debugPrint('  Data: ${response.data}');
    debugPrint(_separator);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('\n[$_tag] ❌ ${err.response?.statusCode} '
        '${err.requestOptions.method} ${err.requestOptions.uri}');
    debugPrint('  Error: ${err.message}');
    if (err.response?.data != null) {
      debugPrint('  Response: ${err.response?.data}');
    }
    debugPrint(_separator);
    handler.next(err);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static const _tag = 'سوزوكي-HTTP';

  /// Masks the Authorization header value for safe logging.
  Map<String, dynamic> _sanitize(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    if (copy.containsKey('Authorization')) {
      copy['Authorization'] = 'Bearer [REDACTED]';
    }
    return copy;
  }
}
