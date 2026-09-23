import 'package:equatable/equatable.dart';

/// User role within the سوزوكي platform.
enum UserRole { passenger, driver }

/// Core domain entity representing an authenticated user.
/// Intentionally free of any JSON/framework dependencies.
class AuthEntity extends Equatable {
  const AuthEntity({
    required this.userId,
    required this.token,
    required this.refreshToken,
    required this.role,
    required this.phone,
    this.fullName,
    this.avatarUrl,
  });

  final String userId;
  final String token;
  final String refreshToken;
  final UserRole role;
  final String phone;
  final String? fullName;
  final String? avatarUrl;

  bool get isDriver => role == UserRole.driver;
  bool get isPassenger => role == UserRole.passenger;

  @override
  List<Object?> get props => [
        userId,
        token,
        refreshToken,
        role,
        phone,
        fullName,
        avatarUrl,
      ];
}
