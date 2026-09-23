import '../../domain/entities/auth_entity.dart';

/// Data-layer model for [AuthEntity].
/// Handles JSON serialization/deserialization from REST API.
class AuthModel extends AuthEntity {
  const AuthModel({
    required super.userId,
    required super.token,
    required super.refreshToken,
    required super.role,
    required super.phone,
    super.fullName,
    super.avatarUrl,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      userId: json['user_id'] as String? ?? json['id'] as String? ?? '',
      token: json['access_token'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      role: _parseRole(json['role'] as String?),
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

  /// Creates an [AuthModel] from a stored JSON map (e.g. SharedPreferences).
  factory AuthModel.fromCacheJson(Map<String, dynamic> json) =>
      AuthModel.fromJson(json);

  static UserRole _parseRole(String? role) {
    if (role == 'driver') return UserRole.driver;
    return UserRole.passenger;
  }

  /// Converts domain entity back to a model (useful for caching).
  factory AuthModel.fromEntity(AuthEntity entity) => AuthModel(
        userId: entity.userId,
        token: entity.token,
        refreshToken: entity.refreshToken,
        role: entity.role,
        phone: entity.phone,
        fullName: entity.fullName,
        avatarUrl: entity.avatarUrl,
      );
}
