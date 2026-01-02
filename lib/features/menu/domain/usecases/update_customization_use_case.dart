import '../../../../core/error/result.dart';
import '../repositories/menu_repository.dart';

class UpdateCustomizationUseCase {
  final MenuRepository _repository;

  UpdateCustomizationUseCase(this._repository);

  Future<Result<void>> call(String id, Map<String, dynamic> data) {
    return _repository.updateCustomizationOption(id, data);
  }
}
