import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/session/session_events.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/auth_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// App-wide session owner. A lazy singleton: the router, the screens and the
/// network layer's "session expired" event all talk to this one instance.
@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo, this._session) : super(const AuthInitial()) {
    _expiredSub = _session.onExpired.listen((_) => _setSignedOut());
  }

  final AuthRepository _repo;
  final SessionEvents _session;
  late final StreamSubscription<void> _expiredSub;

  AuthModel? _user;
  bool? _isNewUser;
  bool _resolved = false;

  /// Signed-in user (used by the router redirect). Null when signed out.
  AuthModel? get currentUser => _user;

  /// True once [checkAuthStatus] finished at least once.
  bool get isResolved => _resolved;
  bool? get isNewUser => _isNewUser;

  /// Called by the splash screen.
  Future<void> checkAuthStatus() async {
    _isNewUser = null;
    final result = await _repo.restoreSession();
    result.fold(
      (failure) {
        _resolved = false;
        _user = null;
        emit(AuthOffline(failure.message));
        debugPrint(
          'Auth restore: resolved=false, profileComplete=null (offline)',
        );
      },
      (user) {
        _resolved = true;
        _isNewUser = null;
        _user = user;
        debugPrint(
          'Auth restore: resolved=true, profileComplete=${user?.profileComplete}',
        );
        if (user == null) {
          emit(const AuthUnauthenticated());
        } else {
          emit(AuthAuthenticated(user));
        }
      },
    );
  }

  /// Returns null on success, or an Arabic error message.
  Future<String?> requestOtp({
    required String phone,
    required UserRole role,
  }) async {
    emit(const AuthLoading());
    final r = await _repo.requestOtp(phone: phone, role: role);
    return r.fold(
      (f) {
        emit(AuthError(f.message));
        return f.message;
      },
      (_) {
        emit(AuthOtpSent(phone: phone));
        return null;
      },
    );
  }

  /// Returns null on success, or an Arabic error message.
  /// On success the router redirect moves the user to the right home.
  Future<String?> verifyOtp({
    required String phone,
    required String code,
  }) async {
    emit(const AuthLoading());
    final r = await _repo.verifyOtp(phone: phone, code: code);
    return r.fold(
      (f) {
        if (f is NetworkFailure) {
          _resolved = false;
          emit(AuthOffline(f.message));
          return f.message;
        }
        if (f.isAuth) {
          _resolved = true;
          _user = null;
          emit(const AuthUnauthenticated());
          return f.message;
        }
        emit(AuthError(f.message));
        return f.message;
      },
      (session) {
        _resolved = true;
        _user = session.user;
        _isNewUser = session.isNewUser;
        debugPrint(
          'Auth OTP /me profileComplete=${session.user.profileComplete}, isNewUser=${session.isNewUser}',
        );
        emit(AuthAuthenticated(session.user, isNewUser: session.isNewUser));
        return null;
      },
    );
  }

  Future<void> retryRestore() => checkAuthStatus();

  /// Re-reads `/users/me`. Silent: never emits loading/error states.
  Future<void> refreshUser() async {
    if (_user == null) return;
    final r = await _repo.refreshUser();
    r.fold((_) {}, (user) {
      _user = user;
      debugPrint('Auth refresh /me profileComplete=${user.profileComplete}');
      emit(AuthAuthenticated(user));
    });
  }

  /// Applies the profile returned by a successful GET /users/me.
  void updateUserFromMe(AuthModel user) {
    _user = user;
    _resolved = true;
    _isNewUser = null;
    debugPrint('Auth profile /me profileComplete=${user.profileComplete}');
    emit(AuthAuthenticated(user));
  }

  Future<void> logout() async {
    await _repo.logout();
    _setSignedOut();
  }

  void _setSignedOut() {
    _user = null;
    _isNewUser = null;
    _resolved = true;
    emit(const AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _expiredSub.cancel();
    return super.close();
  }
}
