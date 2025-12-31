import '../../../../core/error/result.dart';
import '../repositories/menu_repository.dart';

class UpdateMenuAdvancedUseCase {
  final MenuRepository _repository;

  UpdateMenuAdvancedUseCase(this._repository);

  Future<Result<void>> call(String id, Map<String, dynamic> data) {
    return _repository.updateMenuAdvanced(id, data);
  }
}
