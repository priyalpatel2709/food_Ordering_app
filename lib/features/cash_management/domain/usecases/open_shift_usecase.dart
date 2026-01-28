import '../../../../core/error/result.dart';
import '../repositories/cash_register_repository.dart';

class OpenShiftUseCase {
  final CashRegisterRepository _repository;

  OpenShiftUseCase(this._repository);

  Future<Result<void>> execute(
    String id,
    double openingBalance,
    String? notes,
  ) {
    return _repository.openShift(id, openingBalance, notes);
  }
}
