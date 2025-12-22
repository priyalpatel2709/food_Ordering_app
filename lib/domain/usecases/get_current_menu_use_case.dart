import '../../core/error/result.dart';
import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

/// Get Current Menu Use Case
class GetCurrentMenuUseCase {
  final MenuRepository _repository;

  GetCurrentMenuUseCase(this._repository);

  Future<Result<List<MenuEntity>>> execute() {
    return _repository.getCurrentMenu();
  }
}
