import '../../../../core/error/result.dart';
import '../repositories/menu_repository.dart';

class UpdateItemUseCase {
  final MenuRepository _repository;

  UpdateItemUseCase(this._repository);

  Future<Result<void>> call(String id, Map<String, dynamic> data) {
    return _repository.updateItem(id, data);
  }
}
