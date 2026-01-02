import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/error/exceptions.dart';
import '../datasources/tax_remote_data_source.dart';
import '../../domain/entities/tax_entity.dart';
import '../../domain/repositories/tax_repository.dart';

class TaxRepositoryImpl implements TaxRepository {
  final TaxRemoteDataSource _remoteDataSource;

  TaxRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<TaxEntity>>> getAllTaxes() async {
    try {
      final taxes = await _remoteDataSource.getAllTaxes();
      return Result.success(taxes);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> createTax(Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.createTax(data);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateTax(String id, Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.updateTax(id, data);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteTax(String id) async {
    try {
      await _remoteDataSource.deleteTax(id);
      return Result.success(null);
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
