import '../../../../core/error/result.dart';
import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

class GetAllCustomizationsUseCase {
  final MenuRepository _repository;

  GetAllCustomizationsUseCase(this._repository);

  Future<Result<List<CustomizationOptionEntity>>> call() {
    return _repository.getAllCustomizationOptions();
  }
}
