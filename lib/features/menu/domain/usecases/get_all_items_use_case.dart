import '../../../../core/domain/entities/paginated_data.dart';
import '../../../../core/error/result.dart';
import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

class GetAllItemsUseCase {
  final MenuRepository _repository;

  GetAllItemsUseCase(this._repository);

  Future<Result<PaginatedData<MenuItemEntity>>> call({
    int page = 1,
    int limit = 10,
  }) {
    return _repository.getAllItems(page: page, limit: limit);
  }
}
