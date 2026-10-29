import 'package:fpdart/fpdart.dart';

import '../../../../core/network/failures.dart';
import '../models/auth_model.dart';

abstract class AuthRepository {
  /// Sends a 6-digit OTP by SMS to [phone] (`+201XXXXXXXXX`).
  Future<Either<Failure, Unit>> requestOtp({
    required String phone,
    required UserRole role,
  });

  /// Verifies the OTP, stores tokens securely and caches the user.
  Future<Either<Failure, AuthSession>> verifyOtp({
    required String phone,
    required String code,
  });

  /// Re-reads `/users/me` and updates the cached user.
  Future<Either<Failure, AuthModel>> refreshUser();

  /// Revokes the refresh token (best effort) and clears local session.
  Future<void> logout();

  /// Signed-in user from local storage, or null.
  Future<AuthModel?> restoreSession();

  /// Persists an updated user snapshot (after profile/onboarding changes).
  Future<void> cacheUser(AuthModel user);
}
