import '../../../../core/error/result.dart';
import '../entities/tax_entity.dart';

abstract class TaxRepository {
  Future<Result<List<TaxEntity>>> getAllTaxes();
  Future<Result<void>> createTax(Map<String, dynamic> data);
  Future<Result<void>> updateTax(String id, Map<String, dynamic> data);
  Future<Result<void>> deleteTax(String id);
}
