import '../../core/error/result.dart';
import '../repositories/auth_repository.dart';

/// Logout Use Case
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Result<void>> execute() {
    return _repository.logout();
  }
}
