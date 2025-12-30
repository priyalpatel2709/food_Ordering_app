import '../repositories/dine_in_repository.dart';
import '../entities/table_entity.dart';

class GetTablesUseCase {
  final DineInRepository _repository;

  GetTablesUseCase(this._repository);

  Future<List<TableEntity>> call() {
    return _repository.getTables();
  }
}
