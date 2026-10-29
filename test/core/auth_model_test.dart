import 'package:flutter_test/flutter_test.dart';
import 'package:suzuki_app/features/auth/data/models/auth_model.dart';

void main() {
  test('AuthSession parses the enveloped OTP-verify response', () {
    final s = AuthSession.fromJson({
      'data': {
        'access_token': 'a',
        'refresh_token': 'r',
        'is_new_user': true,
        'user': {
          'id': 'u1',
          'phone': '+201012345678',
          'role': 'driver',
          'full_name': 'محمد',
          'profile_complete': false,
          'driver_status': 'pending',
        },
      },
    });
    expect(s.accessToken, 'a');
    expect(s.refreshToken, 'r');
    expect(s.isNewUser, isTrue);
    expect(s.user.isDriver, isTrue);
    expect(s.user.driverStatus, VerificationStatus.pending);
  });

  test('AuthModel survives a cache round trip', () {
    const u = AuthModel(
      userId: 'u1',
      role: UserRole.passenger,
      phone: '+201012345678',
      profileComplete: true,
    );
    expect(AuthModel.fromJson(u.toJson()), u);
  });
}
