import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// Encapsulates the login business rule.
/// Validates inputs before calling the repository.
@injectable
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AuthEntity>> call({
    required String phone,
    required String password,
  }) async {
    // Domain-level validation
    if (phone.trim().isEmpty || password.trim().isEmpty) {
      return Left(
        const ValidationFailure(message: 'رقم الجوال وكلمة المرور مطلوبان'),
      );
    }
    if (password.length < 8) {
      return Left(
        const ValidationFailure(
            message: 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'),
      );
    }
    return _repository.login(phone: phone, password: password);
  }
}
