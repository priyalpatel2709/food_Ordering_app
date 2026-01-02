import '../../../../core/error/result.dart';
import '../repositories/menu_repository.dart';

class DeleteItemUseCase {
  final MenuRepository _repository;

  DeleteItemUseCase(this._repository);

  Future<Result<void>> call(String id) {
    return _repository.deleteItem(id);
  }
}
