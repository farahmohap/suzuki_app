import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/token_storage.dart';
import '../models/auth_model.dart';

/// Local auth storage: tokens → secure storage, device id → prefs.
abstract class AuthLocalDataSource {
  Future<void> saveSession(AuthSession session);
  Future<bool> hasTokens();
  Future<String?> getRefreshToken();
  Future<String> getOrCreateDeviceId();
  Future<void> clearSession();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._prefs, this._tokens);

  final SharedPreferences _prefs;
  final TokenStorage _tokens;

  static const _deviceIdKey = 'device_id';

  @override
  Future<void> saveSession(AuthSession s) async {
    await _tokens.save(access: s.accessToken, refresh: s.refreshToken);
  }

  @override
  Future<bool> hasTokens() async {
    // A refresh token alone is enough to restore the session: the first
    // authenticated request can renew a missing or expired access token.
    final access = await _tokens.readAccess();
    final refresh = await _tokens.readRefresh();
    return (access != null && access.isNotEmpty) ||
        (refresh != null && refresh.isNotEmpty);
  }

  @override
  Future<String?> getRefreshToken() => _tokens.readRefresh();

  @override
  Future<String> getOrCreateDeviceId() async {
    final existing = _prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final rnd = Random.secure();
    final id = List.generate(
      16,
      (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await _prefs.setString(_deviceIdKey, id);
    return id;
  }

  @override
  Future<void> clearSession() async {
    await _tokens.clear();
  }
}
