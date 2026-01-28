import '../../../../core/error/result.dart';
import '../repositories/cash_register_repository.dart';

class CreateRegisterUseCase {
  final CashRegisterRepository _repository;

  CreateRegisterUseCase(this._repository);

  Future<Result<void>> execute(String name) {
    return _repository.createRegister(name);
  }
}
