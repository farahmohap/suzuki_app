import 'package:equatable/equatable.dart';

/// User role within the سوزوكي platform.
enum UserRole {
  passenger,
  driver;

  static UserRole fromString(String? role) {
    if (role == 'driver') return UserRole.driver;
    return UserRole.passenger;
  }
}

/// Data model representing an authenticated user.
class AuthModel extends Equatable {
  const AuthModel({
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

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      userId: json['user_id'] as String? ?? json['id'] as String? ?? '',
      token: json['access_token'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String?),
      phone: json['phone'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'access_token': token,
        'refresh_token': refreshToken,
        'role': role.name,
        'phone': phone,
        'full_name': fullName,
        'avatar_url': avatarUrl,
      };

  factory AuthModel.fromCacheJson(Map<String, dynamic> json) =>
      AuthModel.fromJson(json);

  AuthModel copyWith({
    String? userId,
    String? token,
    String? refreshToken,
    UserRole? role,
    String? phone,
    String? fullName,
    String? avatarUrl,
  }) {
    return AuthModel(
      userId: userId ?? this.userId,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

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
