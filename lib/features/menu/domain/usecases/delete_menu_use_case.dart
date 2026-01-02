import '../../../../core/error/result.dart';
import '../../domain/repositories/menu_repository.dart';

class DeleteMenuUseCase {
  final MenuRepository _repository;

  DeleteMenuUseCase(this._repository);

  Future<Result<void>> call(String id) async {
    return _repository.deleteMenu(id);
  }
}
