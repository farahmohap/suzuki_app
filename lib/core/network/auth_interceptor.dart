import 'package:dio/dio.dart';

import '../session/session_events.dart';
import '../storage/token_storage.dart';
import 'api_endpoints.dart';
import 'api_response.dart';

/// Marks a request that must NOT carry a token and must NOT trigger refresh
/// (OTP request/verify, refresh itself).
const String kSkipAuth = 'skipAuth';
const String _kRetried = 'authRetried';

/// Injects the Bearer token and transparently refreshes it on 401.
///
/// Extends [QueuedInterceptor] so concurrent 401s are handled one at a time:
/// the first refreshes, the rest see the new token and just retry.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required Dio apiDio,
    required Dio refreshDio,
    required TokenStorage tokens,
    required SessionEvents session,
  })  : _api = apiDio,
        _refreshDio = refreshDio,
        _tokens = tokens,
        _session = session;

  final Dio _api; // the Dio this interceptor is attached to (for retry)
  final Dio _refreshDio; // bare Dio, no interceptors (avoids refresh loops)
  final TokenStorage _tokens;
  final SessionEvents _session;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[kSkipAuth] != true) {
      final token = await _tokens.readAccess();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    final is401 = err.response?.statusCode == 401;
    if (!is401 || req.extra[kSkipAuth] == true || req.extra[_kRetried] == true) {
      return handler.next(err);
    }

    // Another queued request may already have refreshed the token.
    final current = await _tokens.readAccess();
    final used = req.headers['Authorization'];
    if (current != null && current.isNotEmpty && 'Bearer $current' != used) {
      return _retry(req, current, handler, err);
    }

    final refresh = await _tokens.readRefresh();
    if (refresh == null || refresh.isEmpty) {
      await _expire();
      return handler.next(err);
    }

    try {
      final res = await _refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refresh},
        options: Options(extra: {kSkipAuth: true}),
      );
      final body = unwrapData(res.data);
      final access = body['access_token'] as String?;
      // Backend rotates refresh tokens: always store the new one.
      final newRefresh = (body['refresh_token'] as String?) ?? refresh;
      if (access == null || access.isEmpty) {
        await _expire();
        return handler.next(err);
      }
      await _tokens.save(access: access, refresh: newRefresh);
      return _retry(req, access, handler, err);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      // Only a definite rejection ends the session; a network blip does not.
      if (code == 400 || code == 401 || code == 403) await _expire();
      return handler.next(err);
    }
  }

  Future<void> _retry(
    RequestOptions req,
    String token,
    ErrorInterceptorHandler handler,
    DioException original,
  ) async {
    req.headers['Authorization'] = 'Bearer $token';
    req.extra[_kRetried] = true;
    try {
      handler.resolve(await _api.fetch(req));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<void> _expire() async {
    await _tokens.clear();
    _session.notifyExpired();
  }
}
