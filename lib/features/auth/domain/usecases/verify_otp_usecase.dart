import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// Verifies the 6-digit OTP code sent to the user's phone.
@injectable
class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AuthEntity>> call({
    required String phone,
    required String otp,
  }) async {
    if (otp.trim().length != 6) {
      return Left(
        const ValidationFailure(message: 'رمز التحقق يجب أن يكون 6 أرقام'),
      );
    }
    if (!RegExp(r'^\d{6}$').hasMatch(otp.trim())) {
      return Left(
        const ValidationFailure(message: 'رمز التحقق يجب أن يحتوي على أرقام فقط'),
      );
    }
    return _repository.verifyOtp(phone: phone, otp: otp.trim());
  }
}

/// Resends an OTP to the given phone number.
@injectable
class ResendOtpUseCase {
  const ResendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, bool>> call({required String phone}) =>
      _repository.resendOtp(phone: phone);
}
