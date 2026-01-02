import '../../../../core/domain/entities/paginated_data.dart';
import '../../../../core/error/result.dart';
import '../entities/tax_entity.dart';

abstract class TaxRepository {
  Future<Result<PaginatedData<TaxEntity>>> getAllTaxes({
    int page = 1,
    int limit = 10,
  });
  Future<Result<void>> createTax(Map<String, dynamic> data);
  Future<Result<void>> updateTax(String id, Map<String, dynamic> data);
  Future<Result<void>> deleteTax(String id);
}
