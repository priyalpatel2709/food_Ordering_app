import '../../../../core/error/result.dart';
import '../repositories/menu_repository.dart';

class DeleteCustomizationUseCase {
  final MenuRepository _repository;

  DeleteCustomizationUseCase(this._repository);

  Future<Result<void>> call(String id) {
    return _repository.deleteCustomizationOption(id);
  }
}
