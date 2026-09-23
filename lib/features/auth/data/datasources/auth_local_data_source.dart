import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_model.dart';

/// Contract for local auth storage operations.
abstract class AuthLocalDataSource {
  Future<void> cacheUser(AuthModel user);
  Future<AuthModel?> getCachedUser();
  Future<void> saveToken(String token, String refreshToken);
  Future<String?> getToken();
  Future<String?> getRefreshToken();
  Future<void> saveRole(String role);
  Future<String?> getRole();
  Future<void> clearSession();
}

/// [SharedPreferences]-backed implementation.
@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _cachedUserKey = 'cached_user';
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _roleKey = 'user_role';

  @override
  Future<void> cacheUser(AuthModel user) async {
    try {
      await _prefs.setString(_cachedUserKey, jsonEncode(user.toJson()));
    } catch (e) {
      throw const CacheException(message: 'تعذّر حفظ بيانات المستخدم');
    }
  }

  @override
  Future<AuthModel?> getCachedUser() async {
    final json = _prefs.getString(_cachedUserKey);
    if (json == null) return null;
    try {
      return AuthModel.fromCacheJson(
          jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveToken(String token, String refreshToken) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setString(_refreshTokenKey, refreshToken);
  }

  @override
  Future<String?> getToken() async => _prefs.getString(_tokenKey);

  @override
  Future<String?> getRefreshToken() async =>
      _prefs.getString(_refreshTokenKey);

  @override
  Future<void> saveRole(String role) async =>
      _prefs.setString(_roleKey, role);

  @override
  Future<String?> getRole() async => _prefs.getString(_roleKey);

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _prefs.remove(_cachedUserKey),
      _prefs.remove(_tokenKey),
      _prefs.remove(_refreshTokenKey),
      _prefs.remove(_roleKey),
    ]);
  }
}
