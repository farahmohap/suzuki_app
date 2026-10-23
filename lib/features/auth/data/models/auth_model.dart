import 'package:equatable/equatable.dart';

import '../../../../core/network/api_response.dart';

/// User role within the platform.
enum UserRole {
  passenger,
  driver;

  static UserRole fromString(String? role) =>
      role == 'driver' ? UserRole.driver : UserRole.passenger;

  String get apiValue => name;
}

/// Driver verification lifecycle (backend `driver_profiles.verification_status`).
enum VerificationStatus {
  /// Not a driver, or onboarding not started.
  none,
  draft,
  pending,
  approved,
  rejected,
  suspended;

  static VerificationStatus fromString(String? s) {
    for (final v in VerificationStatus.values) {
      if (v.name == s) return v;
    }
    return VerificationStatus.none;
  }
}

/// The signed-in user (no tokens — those live in secure storage).
class AuthModel extends Equatable {
  const AuthModel({
    required this.userId,
    required this.role,
    required this.phone,
    this.fullName,
    this.avatarUrl,
    this.profileComplete = false,
    this.driverStatus = VerificationStatus.none,
  });

  final String userId;
  final UserRole role;
  final String phone;
  final String? fullName;
  final String? avatarUrl;

  /// Passenger: name/district/address/location saved.
  final bool profileComplete;

  /// Driver only.
  final VerificationStatus driverStatus;

  bool get isDriver => role == UserRole.driver;
  bool get isPassenger => role == UserRole.passenger;

  /// Accepts `{data:{user:{...}}}`, `{user:{...}}` or a bare user object.
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final body = unwrapData(json);
    final u = body['user'] is Map<String, dynamic>
        ? body['user'] as Map<String, dynamic>
        : body;
    return AuthModel(
      userId: (u['id'] ?? u['user_id'] ?? '').toString(),
      role: UserRole.fromString(u['role'] as String?),
      phone: u['phone'] as String? ?? '',
      fullName: u['full_name'] as String?,
      avatarUrl: u['avatar_url'] as String?,
      profileComplete: u['profile_complete'] as bool? ?? false,
      driverStatus: VerificationStatus.fromString(
        (u['driver_status'] ?? u['verification_status']) as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': userId,
        'role': role.apiValue,
        'phone': phone,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'profile_complete': profileComplete,
        'driver_status': driverStatus.name,
      };

  AuthModel copyWith({
    String? fullName,
    String? avatarUrl,
    bool? profileComplete,
    VerificationStatus? driverStatus,
  }) =>
      AuthModel(
        userId: userId,
        role: role,
        phone: phone,
        fullName: fullName ?? this.fullName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        profileComplete: profileComplete ?? this.profileComplete,
        driverStatus: driverStatus ?? this.driverStatus,
      );

  @override
  List<Object?> get props =>
      [userId, role, phone, fullName, avatarUrl, profileComplete, driverStatus];
}

/// Result of a successful OTP verification.
class AuthSession extends Equatable {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
  });

  final AuthModel user;
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final body = unwrapData(json);
    return AuthSession(
      user: AuthModel.fromJson(body),
      accessToken: body['access_token'] as String? ?? '',
      refreshToken: body['refresh_token'] as String? ?? '',
      isNewUser: body['is_new_user'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [user, accessToken, refreshToken, isNewUser];
}
