import '../repositories/dine_in_repository.dart';

class DeleteTableUseCase {
  final DineInRepository _repository;

  DeleteTableUseCase(this._repository);

  Future<void> call(String id) async {
    return await _repository.deleteTable(id);
  }
}
