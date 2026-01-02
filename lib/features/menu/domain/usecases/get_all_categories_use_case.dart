import '../../../../core/error/result.dart';
import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

class GetAllCategoriesUseCase {
  final MenuRepository _repository;

  GetAllCategoriesUseCase(this._repository);

  Future<Result<List<CategoryEntity>>> call() {
    return _repository.getAllCategories();
  }
}
