import '../../../../core/error/result.dart';
import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

class GetAllItemsUseCase {
  final MenuRepository _repository;

  GetAllItemsUseCase(this._repository);

  Future<Result<List<MenuItemEntity>>> call() {
    return _repository.getAllItems();
  }
}
