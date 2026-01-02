import '../../../../core/error/result.dart';
import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

class GetMenuByIdUseCase {
  final MenuRepository _repository;

  GetMenuByIdUseCase(this._repository);

  Future<Result<MenuEntity>> call(String id) {
    return _repository.getMenuById(id);
  }
}
