import '../../../../core/error/result.dart';
import '../repositories/menu_repository.dart';

class UpdateMenuUseCase {
  final MenuRepository _repository;

  UpdateMenuUseCase(this._repository);

  Future<Result<void>> call(String id, Map<String, dynamic> data) {
    return _repository.updateMenu(id, data);
  }
}
