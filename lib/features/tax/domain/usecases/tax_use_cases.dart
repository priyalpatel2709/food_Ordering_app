import '../../../../core/domain/entities/paginated_data.dart';
import '../../../../core/error/result.dart';
import '../entities/tax_entity.dart';
import '../repositories/tax_repository.dart';

class GetAllTaxesUseCase {
  final TaxRepository _repository;

  GetAllTaxesUseCase(this._repository);

  Future<Result<PaginatedData<TaxEntity>>> call({
    int page = 1,
    int limit = 10,
  }) {
    return _repository.getAllTaxes(page: page, limit: limit);
  }
}

class CreateTaxUseCase {
  final TaxRepository _repository;

  CreateTaxUseCase(this._repository);

  Future<Result<void>> call(Map<String, dynamic> data) {
    return _repository.createTax(data);
  }
}

class UpdateTaxUseCase {
  final TaxRepository _repository;

  UpdateTaxUseCase(this._repository);

  Future<Result<void>> call(String id, Map<String, dynamic> data) {
    return _repository.updateTax(id, data);
  }
}

class DeleteTaxUseCase {
  final TaxRepository _repository;

  DeleteTaxUseCase(this._repository);

  Future<Result<void>> call(String id) {
    return _repository.deleteTax(id);
  }
}
