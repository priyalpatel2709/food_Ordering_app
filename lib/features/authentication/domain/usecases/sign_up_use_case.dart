import '../../../../core/error/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Sign Up Use Case
class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<Result<UserEntity>> execute({
    required String name,
    required String email,
    required String password,
    required String restaurantId,
  }) {
    return _repository.signUp(
      name: name,
      email: email,
      password: password,
      restaurantId: restaurantId,
    );
  }
}
