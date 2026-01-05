import '../../../../core/domain/entities/paginated_data.dart';
import '../../../../core/error/result.dart';
import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

class GetAllCustomizationsUseCase {
  final MenuRepository _repository;

  GetAllCustomizationsUseCase(this._repository);

  Future<Result<PaginatedData<CustomizationOptionEntity>>> call({
    int page = 1,
    int limit = 10,
    String? search,
  }) {
    return _repository.getAllCustomizationOptions(
      page: page,
      limit: limit,
      search: search,
    );
  }
}
