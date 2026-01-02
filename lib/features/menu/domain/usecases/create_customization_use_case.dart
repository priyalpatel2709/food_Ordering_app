import '../../../../core/error/result.dart';
import '../repositories/menu_repository.dart';

class CreateCustomizationUseCase {
  final MenuRepository _repository;

  CreateCustomizationUseCase(this._repository);

  Future<Result<void>> call(Map<String, dynamic> data) {
    return _repository.createCustomizationOption(data);
  }
}
