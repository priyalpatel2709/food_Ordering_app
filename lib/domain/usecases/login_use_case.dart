import '../../core/error/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Login Use Case
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Result<UserEntity>> execute(String email, String password) {
    return _repository.login(email, password);
  }
}
