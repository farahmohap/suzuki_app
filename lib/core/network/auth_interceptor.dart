import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Injects the Bearer auth token into every outgoing request.
/// Handles 401 responses: attempts one token refresh, then clears session.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio);

  final Dio _dio;

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';

  // ── Request ─────────────────────────────────────────────────────────────────
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ── Error / 401 Refresh Logic ───────────────────────────────────────────────
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        // Retry original request with new token
        final token = await _getToken();
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $token';
        try {
          final response = await _dio.fetch(opts);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      } else {
        await _clearSession();
      }
    }
    handler.next(err);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refresh = prefs.getString(_refreshTokenKey);
      if (refresh == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refresh},
        options: Options(
          headers: {'Authorization': null}, // Skip auth interceptor
        ),
      );

      final newToken = response.data['access_token'] as String?;
      if (newToken != null) {
        await prefs.setString(_tokenKey, newToken);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
