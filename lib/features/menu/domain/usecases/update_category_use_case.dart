import '../../../../core/error/result.dart';
import '../repositories/menu_repository.dart';

class UpdateCategoryUseCase {
  final MenuRepository _repository;

  UpdateCategoryUseCase(this._repository);

  Future<Result<void>> call(String id, Map<String, dynamic> data) {
    return _repository.updateCategory(id, data);
  }
}
