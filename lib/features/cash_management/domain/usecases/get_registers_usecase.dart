import '../../../../core/error/result.dart';
import '../entities/cash_register.dart';
import '../repositories/cash_register_repository.dart';

class GetRegistersUseCase {
  final CashRegisterRepository _repository;

  GetRegistersUseCase(this._repository);

  Future<Result<List<CashRegisterEntity>>> execute() {
    return _repository.getRegisters();
  }
}
