import '../../../../core/error/result.dart';
import '../repositories/menu_repository.dart';

class DeleteCategoryUseCase {
  final MenuRepository _repository;

  DeleteCategoryUseCase(this._repository);

  Future<Result<void>> call(String id) {
    return _repository.deleteCategory(id);
  }
}
