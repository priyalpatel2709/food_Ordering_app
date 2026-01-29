import '../../../../core/error/result.dart';
import '../entities/cash_history.dart';
import '../repositories/cash_register_repository.dart';

class GetHistoryUseCase {
  final CashRegisterRepository _repository;

  GetHistoryUseCase(this._repository);

  Future<Result<List<CashHistoryEntity>>> execute(String id) {
    return _repository.getHistory(id);
  }
}
