import '../entities/table_entity.dart';
import '../repositories/dine_in_repository.dart';

class CreateTableUseCase {
  final DineInRepository _repository;

  CreateTableUseCase(this._repository);

  Future<TableEntity> call(String tableNumber, int capacity) async {
    return await _repository.createTable(tableNumber, capacity);
  }
}
