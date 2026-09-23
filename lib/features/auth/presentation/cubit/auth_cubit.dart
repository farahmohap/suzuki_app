import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Manages authentication lifecycle: login, register, OTP, and logout.
/// Interacts directly with [AuthRepository] without use cases.
@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
  })  : _authRepo = authRepository,
        super(const AuthInitial());

  final AuthRepository _authRepo;

  /// Checks stored token and emits [AuthAuthenticated] or [AuthUnauthenticated].
  Future<void> checkAuthStatus() async {
    final isAuth = await _authRepo.isAuthenticated();
    if (isAuth) {
      final user = await _authRepo.getCachedUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Attempts login with [phone] + [password].
  Future<void> login({required String phone, required String password}) async {
    emit(const AuthLoading());
    final result = await _authRepo.login(phone: phone, password: password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Registers a new user account.
  Future<void> register({
    required String phone,
    required String password,
    required String fullName,
    required String role,
  }) async {
    emit(const AuthLoading());
    final result = await _authRepo.register(
      phone: phone,
      password: password,
      fullName: fullName,
      role: role,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthOtpSent(phone: phone)),
    );
  }

  /// Verifies OTP entered by user.
  Future<void> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    emit(const AuthLoading());
    final result = await _authRepo.verifyOtp(phone: phone, otp: otp);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Resends OTP to [phone].
  Future<void> resendOtp({required String phone}) async {
    final result = await _authRepo.resendOtp(phone: phone);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthOtpResent(phone: phone)),
    );
  }

  /// Logs out the current user.
  Future<void> logout() async {
    emit(const AuthLoading());
    final result = await _authRepo.logout();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
