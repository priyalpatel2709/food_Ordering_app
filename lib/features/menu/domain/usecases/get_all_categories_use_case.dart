import '../../../../core/domain/entities/paginated_data.dart';
import '../../../../core/error/result.dart';
import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

class GetAllCategoriesUseCase {
  final MenuRepository _repository;

  GetAllCategoriesUseCase(this._repository);

  Future<Result<PaginatedData<CategoryEntity>>> call({
    int page = 1,
    int limit = 10,
    String? search,
  }) {
    return _repository.getAllCategories(
      page: page,
      limit: limit,
      search: search,
    );
  }
}
