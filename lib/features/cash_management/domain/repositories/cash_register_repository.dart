import '../../../../core/error/result.dart';
import '../entities/cash_register.dart';
import '../entities/cash_history.dart';
import '../entities/cash_shift_summary.dart';

abstract class CashRegisterRepository {
  Future<Result<List<CashRegisterEntity>>> getRegisters();

  Future<Result<void>> createRegister(String name);

  Future<Result<void>> openShift(
    String id,
    double openingBalance,
    String? notes,
  );

  Future<Result<void>> addTransaction(
    String id,
    String type,
    double amount,
    String reason,
  );

  Future<Result<CashShiftSummaryEntity>> closeShift(
    String id,
    double actualCash,
    String? notes,
  );

  Future<Result<List<CashHistoryEntity>>> getHistory(String id);
}
