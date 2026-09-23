import 'package:fpdart/fpdart.dart';
import '../../../../core/network/failures.dart';
import '../models/auth_model.dart';

/// Contract for auth operations returning [AuthModel] directly.
abstract class AuthRepository {
  /// Authenticates user with phone + password.
  Future<Either<Failure, AuthModel>> login({
    required String phone,
    required String password,
  });

  /// Registers a new user account.
  Future<Either<Failure, AuthModel>> register({
    required String phone,
    required String password,
    required String fullName,
    required String role,
  });

  /// Verifies the OTP sent to [phone].
  Future<Either<Failure, AuthModel>> verifyOtp({
    required String phone,
    required String otp,
  });

  /// Resends OTP to [phone].
  Future<Either<Failure, bool>> resendOtp({required String phone});

  /// Logs out the current user (clears local session).
  Future<Either<Failure, bool>> logout();

  /// Checks whether a valid auth token exists locally.
  Future<bool> isAuthenticated();

  /// Returns the cached [AuthModel] if available.
  Future<AuthModel?> getCachedUser();
}
