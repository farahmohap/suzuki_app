import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';

/// Contract for auth operations.
/// Implemented in the data layer — domain only depends on this abstraction.
abstract class AuthRepository {
  /// Authenticates user with phone + password.
  /// Returns [AuthEntity] on success, [Failure] on error.
  Future<Either<Failure, AuthEntity>> login({
    required String phone,
    required String password,
  });

  /// Registers a new user account.
  Future<Either<Failure, AuthEntity>> register({
    required String phone,
    required String password,
    required String fullName,
    required String role,
  });

  /// Verifies the OTP sent to [phone].
  Future<Either<Failure, AuthEntity>> verifyOtp({
    required String phone,
    required String otp,
  });

  /// Resends OTP to [phone].
  Future<Either<Failure, bool>> resendOtp({required String phone});

  /// Logs out the current user (clears local session).
  Future<Either<Failure, bool>> logout();

  /// Checks whether a valid auth token exists locally.
  Future<bool> isAuthenticated();

  /// Returns the cached [AuthEntity] if available.
  Future<AuthEntity?> getCachedUser();
}
