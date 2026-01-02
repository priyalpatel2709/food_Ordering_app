import '../../../../core/error/result.dart';
import '../repositories/menu_repository.dart';

class CreateCategoryUseCase {
  final MenuRepository _repository;

  CreateCategoryUseCase(this._repository);

  Future<Result<void>> call(Map<String, dynamic> data) {
    return _repository.createCategory(data);
  }
}
