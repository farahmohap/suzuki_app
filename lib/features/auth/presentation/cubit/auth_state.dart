import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entity.dart';

/// Immutable sealed state hierarchy for [AuthCubit].
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no action taken yet.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A long-running auth operation is in progress.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authentication succeeded.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AuthEntity user;

  @override
  List<Object?> get props => [user];
}

/// User is confirmed unauthenticated (logged out / no token).
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An auth operation failed.
final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// OTP has been sent — waiting for verification.
final class AuthOtpSent extends AuthState {
  const AuthOtpSent({required this.phone});

  final String phone;

  @override
  List<Object?> get props => [phone];
}

/// OTP resend succeeded.
final class AuthOtpResent extends AuthState {
  const AuthOtpResent({required this.phone});

  final String phone;

  @override
  List<Object?> get props => [phone];
}
