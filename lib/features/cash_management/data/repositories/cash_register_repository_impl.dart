import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/cash_register.dart';
import '../../domain/entities/cash_history.dart';
import '../../domain/entities/cash_shift_summary.dart';
import '../../domain/repositories/cash_register_repository.dart';
import '../datasources/cash_register_remote_data_source.dart';

class CashRegisterRepositoryImpl implements CashRegisterRepository {
  final CashRegisterRemoteDataSource _remoteDataSource;

  CashRegisterRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<CashRegisterEntity>>> getRegisters() async {
    try {
      final dtos = await _remoteDataSource.getRegisters();
      return Result.success(dtos.map((dto) => dto.toEntity()).toList());
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
  Future<Result<void>> createRegister(String name) async {
    try {
      await _remoteDataSource.createRegister(name);
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
  Future<Result<void>> openShift(
    String id,
    double openingBalance,
    String? notes,
  ) async {
    try {
      await _remoteDataSource.openShift(id, openingBalance, notes);
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
  Future<Result<void>> addTransaction(
    String id,
    String type,
    double amount,
    String reason,
  ) async {
    try {
      await _remoteDataSource.addTransaction(id, type, amount, reason);
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
  Future<Result<CashShiftSummaryEntity>> closeShift(
    String id,
    double actualCash,
    String? notes,
  ) async {
    try {
      final dto = await _remoteDataSource.closeShift(id, actualCash, notes);
      return Result.success(dto.toEntity());
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
  Future<Result<List<CashHistoryEntity>>> getHistory(String id) async {
    try {
      final dtos = await _remoteDataSource.getHistory(id);
      return Result.success(dtos.map((dto) => dto.toEntity()).toList());
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
