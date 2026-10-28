import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/session/session_events.dart';
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
  bool _resolved = false;
  bool _previewDriverSession = false;

  /// Signed-in user (used by the router redirect). Null when signed out.
  AuthModel? get currentUser => _user;

  /// True once [checkAuthStatus] finished at least once.
  bool get isResolved => _resolved;

  /// True for the temporary no-API driver onboarding review flow.
  bool get isPreviewDriverSession => _previewDriverSession;

  /// Creates an in-memory driver session for reviewing onboarding screens.
  /// No tokens or user data are sent to or saved from the backend.
  void beginDriverPreviewSession({required String phone}) {
    _resolved = true;
    _previewDriverSession = true;
    _user = AuthModel(
      userId: 'driver-preview',
      role: UserRole.driver,
      phone: phone,
      driverStatus: VerificationStatus.none,
    );
    emit(AuthAuthenticated(_user!));
  }

  /// Called by the splash screen.
  Future<void> checkAuthStatus() async {
    final user = await _repo.restoreSession();
    _resolved = true;
    if (user == null) {
      _user = null;
      emit(const AuthUnauthenticated());
      return;
    }
    _user = user;
    emit(AuthAuthenticated(user));
    unawaited(refreshUser()); // silent refresh; fixes stale driver status
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
        emit(AuthError(f.message));
        return f.message;
      },
      (session) {
        _resolved = true;
        _user = session.user;
        emit(AuthAuthenticated(session.user, isNewUser: session.isNewUser));
        return null;
      },
    );
  }

  /// Re-reads `/users/me`. Silent: never emits loading/error states.
  Future<void> refreshUser() async {
    if (_user == null) return;
    final r = await _repo.refreshUser();
    r.fold((_) {}, (user) {
      _user = user;
      emit(AuthAuthenticated(user));
    });
  }

  /// Applies a user returned by profile/onboarding calls.
  Future<void> updateUser(AuthModel user) async {
    _user = user;
    await _repo.cacheUser(user);
    emit(AuthAuthenticated(user));
  }

  Future<void> logout() async {
    if (_previewDriverSession) {
      _setSignedOut();
      return;
    }
    await _repo.logout();
    _setSignedOut();
  }

  void _setSignedOut() {
    _user = null;
    _previewDriverSession = false;
    _resolved = true;
    emit(const AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _expiredSub.cancel();
    return super.close();
  }
}
