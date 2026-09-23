import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Manages authentication lifecycle: login, register, OTP, and logout.
///
/// Emits [AuthState] variants to drive UI transitions.
@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required ResendOtpUseCase resendOtpUseCase,
    required AuthRepository authRepository,
  })  : _login = loginUseCase,
        _register = registerUseCase,
        _verifyOtp = verifyOtpUseCase,
        _resendOtp = resendOtpUseCase,
        _authRepo = authRepository,
        super(const AuthInitial());

  final LoginUseCase _login;
  final RegisterUseCase _register;
  final VerifyOtpUseCase _verifyOtp;
  final ResendOtpUseCase _resendOtp;
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
    final result = await _login(phone: phone, password: password);
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
    final result = await _register(
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
    final result = await _verifyOtp(phone: phone, otp: otp);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Resends OTP to [phone].
  Future<void> resendOtp({required String phone}) async {
    final result = await _resendOtp(phone: phone);
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
