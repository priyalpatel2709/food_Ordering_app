import '../../../../core/error/result.dart';
import '../repositories/menu_repository.dart';

class AddItemToMenuUseCase {
  final MenuRepository _repository;

  AddItemToMenuUseCase(this._repository);

  Future<Result<void>> call(String menuId, Map<String, dynamic> itemData) {
    return _repository.addItemToMenu(menuId, itemData);
  }
}
