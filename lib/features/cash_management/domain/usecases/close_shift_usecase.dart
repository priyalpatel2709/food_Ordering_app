import '../../../../core/error/result.dart';
import '../repositories/cash_register_repository.dart';

class CloseShiftUseCase {
  final CashRegisterRepository _repository;

  CloseShiftUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> execute(
    String id,
    double actualCash,
    String? notes,
  ) {
    return _repository.closeShift(id, actualCash, notes);
  }
}
