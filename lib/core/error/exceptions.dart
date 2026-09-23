/// Base [AppException] and concrete exception classes.
/// Exceptions are thrown from data-layer code and caught in
/// repository implementations, which convert them to [Failure] instances.
sealed class AppException implements Exception {
  const AppException({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

// ── Concrete Exceptions ────────────────────────────────────────────────────

/// Thrown when the Dio HTTP call returns a non-2xx status or bad body.
final class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    this.statusCode,
  });

  final int? statusCode;
}

/// Thrown when there is no network connectivity or a connection timeout.
final class NetworkException extends AppException {
  const NetworkException({
    super.message = 'لا يوجد اتصال بالإنترنت',
    super.code = 'NETWORK_ERROR',
  });
}

/// Thrown when a local storage read/write fails (Hive / SharedPreferences).
final class CacheException extends AppException {
  const CacheException({
    super.message = 'خطأ في قاعدة البيانات المحلية',
    super.code = 'CACHE_ERROR',
  });
}

/// Thrown when a required auth token is missing or malformed.
final class AuthException extends AppException {
  const AuthException({
    super.message = 'غير مصرح لك بالوصول',
    super.code = 'AUTH_ERROR',
  });
}

/// Thrown when a token has expired and refresh failed.
final class SessionExpiredException extends AppException {
  const SessionExpiredException({
    super.message = 'انتهت جلستك، يرجى تسجيل الدخول مجددًا',
    super.code = 'SESSION_EXPIRED',
  });
}
