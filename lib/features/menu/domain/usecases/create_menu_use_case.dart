import '../../../../core/error/result.dart';
import '../repositories/menu_repository.dart';

class CreateMenuUseCase {
  final MenuRepository _repository;

  CreateMenuUseCase(this._repository);

  Future<Result<void>> call(Map<String, dynamic> data) {
    return _repository.createMenu(data);
  }
}
