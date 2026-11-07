import 'package:fpdart/fpdart.dart';

import '../../../../core/network/failures.dart';
import '../models/auth_model.dart';

abstract class AuthRepository {
  /// Sends a 6-digit OTP by SMS to [phone] (`+201XXXXXXXXX`).
  Future<Either<Failure, Unit>> requestOtp({
    required String phone,
    required UserRole role,
  });

  /// Verifies OTP, stores tokens securely, then loads the user from /me.
  Future<Either<Failure, AuthSession>> verifyOtp({
    required String phone,
    required String code,
  });

  /// Re-reads `/users/me` and updates the cached user.
  Future<Either<Failure, AuthModel>> refreshUser();

  /// Revokes the refresh token (best effort) and clears local session.
  Future<void> logout();

  /// Restores a session from secure tokens and GET /users/me.
  Future<Either<Failure, AuthModel?>> restoreSession();
}
