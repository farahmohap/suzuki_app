import 'dart:convert';
import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_model.dart';

/// Local auth storage: tokens → secure storage, user snapshot/device id → prefs.
abstract class AuthLocalDataSource {
  Future<void> saveSession(AuthSession session);
  Future<void> cacheUser(AuthModel user);
  Future<AuthModel?> getCachedUser();
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

  static const _cachedUserKey = 'cached_user';
  static const _deviceIdKey = 'device_id';

  @override
  Future<void> saveSession(AuthSession s) async {
    await _tokens.save(access: s.accessToken, refresh: s.refreshToken);
    await cacheUser(s.user);
  }

  @override
  Future<void> cacheUser(AuthModel user) async {
    try {
      await _prefs.setString(_cachedUserKey, jsonEncode(user.toJson()));
    } catch (_) {
      throw const CacheException(message: 'تعذّر حفظ بيانات المستخدم');
    }
  }

  @override
  Future<AuthModel?> getCachedUser() async {
    final raw = _prefs.getString(_cachedUserKey);
    if (raw == null) return null;
    try {
      return AuthModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> hasTokens() async {
    final t = await _tokens.readAccess();
    return t != null && t.isNotEmpty;
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
    await _prefs.remove(_cachedUserKey);
  }
}
