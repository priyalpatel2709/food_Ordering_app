import '../entities/table_entity.dart';
import '../repositories/dine_in_repository.dart';

class UpdateTableUseCase {
  final DineInRepository _repository;

  UpdateTableUseCase(this._repository);

  Future<TableEntity> call(
    String id,
    String tableNumber,
    int capacity,
    TableStatus status,
  ) async {
    return await _repository.updateTable(id, tableNumber, capacity, status);
  }
}
