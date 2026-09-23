import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// Handles new account registration for both passenger and driver roles.
@injectable
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AuthEntity>> call({
    required String phone,
    required String password,
    required String fullName,
    required String role, // 'passenger' | 'driver'
  }) async {
    if (phone.trim().isEmpty) {
      return Left(const ValidationFailure(message: 'رقم الجوال مطلوب'));
    }
    if (fullName.trim().length < 3) {
      return Left(
          const ValidationFailure(message: 'الاسم يجب أن يكون 3 أحرف على الأقل'));
    }
    if (password.length < 8) {
      return Left(const ValidationFailure(
          message: 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'));
    }
    if (role != 'passenger' && role != 'driver') {
      return Left(const ValidationFailure(message: 'نوع الحساب غير صحيح'));
    }
    return _repository.register(
      phone: phone,
      password: password,
      fullName: fullName,
      role: role,
    );
  }
}
