import 'package:flutter_test/flutter_test.dart';
import 'package:suzuki_app/core/router/auth_redirect.dart';
import 'package:suzuki_app/features/auth/data/models/auth_model.dart';

AuthModel passenger({bool complete = true}) => AuthModel(
      userId: '1',
      role: UserRole.passenger,
      phone: '+201012345678',
      profileComplete: complete,
    );

AuthModel driver(VerificationStatus s) => AuthModel(
      userId: '2',
      role: UserRole.driver,
      phone: '+201112345678',
      driverStatus: s,
    );

String? go(AuthModel? u, String loc, {bool resolved = true}) =>
    resolveRedirect(resolved: resolved, user: u, location: loc);

void main() {
  test('unresolved session stays on splash', () {
    expect(go(null, '/login', resolved: false), '/');
    expect(go(null, '/', resolved: false), isNull);
  });

  test('signed-out user can only see login / otp', () {
    expect(go(null, '/passenger/home'), '/login');
    expect(go(null, '/driver/dashboard'), '/login');
    expect(go(null, '/login'), isNull);
    expect(go(null, '/otp'), isNull);
  });

  group('passenger', () {
    test('without profile is sent to profile setup', () {
      expect(go(passenger(complete: false), '/passenger/home'), '/register');
      expect(go(passenger(complete: false), '/otp'), '/register');
      expect(go(passenger(complete: false), '/register'), isNull);
    });
    test('with profile goes home and cannot open driver area', () {
      expect(go(passenger(), '/'), '/passenger/home');
      expect(go(passenger(), '/register'), '/passenger/home');
      expect(go(passenger(), '/driver/dashboard'), '/passenger/home');
      expect(go(passenger(), '/passenger/profile'), isNull);
    });
  });

  group('driver', () {
    test('new driver starts onboarding', () {
      for (final s in [VerificationStatus.none, VerificationStatus.draft]) {
        expect(go(driver(s), '/otp'), '/driver/onboarding');
        expect(go(driver(s), '/driver/onboarding'), isNull);
        expect(go(driver(s), '/driver/dashboard'), '/driver/onboarding');
      }
    });
    test('pending / rejected / suspended see the status screen', () {
      for (final s in [
        VerificationStatus.pending,
        VerificationStatus.rejected,
        VerificationStatus.suspended,
      ]) {
        expect(go(driver(s), '/otp'), '/driver/status');
        expect(go(driver(s), '/driver/status'), isNull);
        expect(go(driver(s), '/driver/onboarding'), '/driver/status');
        expect(go(driver(s), '/driver/dashboard'), '/driver/status');
      }
    });
    test('approved driver reaches the dashboard only', () {
      final d = driver(VerificationStatus.approved);
      expect(go(d, '/'), '/driver/dashboard');
      expect(go(d, '/driver/status'), '/driver/dashboard');
      expect(go(d, '/driver/earnings'), isNull);
      expect(go(d, '/passenger/home'), '/driver/dashboard');
    });
  });
}
