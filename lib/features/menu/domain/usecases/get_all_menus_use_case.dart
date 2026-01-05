import '../../../../core/domain/entities/paginated_data.dart';
import '../../../../core/error/result.dart';
import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

class GetAllMenusUseCase {
  final MenuRepository repository;

  GetAllMenusUseCase(this.repository);

  Future<Result<PaginatedData<MenuEntity>>> call({
    int page = 1,
    int limit = 10,
    String? search,
  }) {
    return repository.getAllMenus(page: page, limit: limit, search: search);
  }
}
