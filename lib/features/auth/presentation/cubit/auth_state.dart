import 'package:equatable/equatable.dart';

import '../../data/models/auth_model.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// App just started; session not yet checked.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A network operation (OTP request / verify) is in progress.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user, {this.isNewUser = false});

  final AuthModel user;
  final bool isNewUser;

  @override
  List<Object?> get props => [user, isNewUser];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// OTP sent; the OTP screen is waiting for the code.
final class AuthOtpSent extends AuthState {
  const AuthOtpSent({required this.phone});

  final String phone;

  @override
  List<Object?> get props => [phone];
}
