import '../../../../core/error/result.dart';
import '../repositories/cash_register_repository.dart';

class AddTransactionUseCase {
  final CashRegisterRepository _repository;

  AddTransactionUseCase(this._repository);

  Future<Result<void>> execute(
    String id,
    String type,
    double amount,
    String reason,
  ) {
    return _repository.addTransaction(id, type, amount, reason);
  }
}
