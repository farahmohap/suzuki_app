import 'package:fpdart/fpdart.dart';
import 'exceptions.dart';

/// Base [Failure] sealed class for the fpdart Either<Failure, T> pattern.
/// Every failure carries a human-readable [message] (Arabic) and an
/// optional technical [code] for logging/debugging.
sealed class Failure {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

// ── Concrete Failures ──────────────────────────────────────────────────────

/// Remote API returned a non-2xx status or an unexpected body.
final class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'خطأ في الخادم، يرجى المحاولة لاحقًا',
    super.code,
    this.statusCode,
  });

  final int? statusCode;

  factory ServerFailure.fromException(ServerException e) => ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
}

/// Device has no internet connection or request timed out.
final class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'تحقق من اتصالك بالإنترنت',
    super.code = 'NETWORK_ERROR',
  });

  factory NetworkFailure.fromException(NetworkException e) => NetworkFailure(
        message: e.message,
        code: e.code,
      );
}

/// Local database / Hive / SharedPreferences operation failed.
final class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'تعذّر تحميل البيانات المحلية',
    super.code = 'CACHE_ERROR',
  });

  factory CacheFailure.fromException(CacheException e) => CacheFailure(
        message: e.message,
        code: e.code,
      );
}

/// Authentication/authorization failed (401 / 403).
final class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'بيانات الدخول غير صحيحة',
    super.code = 'AUTH_ERROR',
  });
}

/// Session expired — token is missing or no longer valid.
final class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure({
    super.message = 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجددًا',
    super.code = 'SESSION_EXPIRED',
  });
}

/// Client-side input/business rule validation error.
final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code = 'VALIDATION'});
}

/// Catch-all for any unexpected failures.
final class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا',
    super.code = 'UNKNOWN',
  });
}

// ── Helper extensions ──────────────────────────────────────────────────────

extension FailureX on Failure {
  /// Returns a [Left] wrapping this failure — convenient for use-case returns.
  Either<Failure, Never> get left => Left(this);

  bool get isNetwork => this is NetworkFailure;
  bool get isAuth => this is AuthFailure || this is SessionExpiredFailure;
  bool get isServer => this is ServerFailure;
  bool get isCache => this is CacheFailure;
}
