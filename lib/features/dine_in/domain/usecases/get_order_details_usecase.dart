import '../repositories/dine_in_repository.dart';
import '../entities/dine_in_order_entity.dart';

class GetDineInOrderDetailsUseCase {
  final DineInRepository _repository;

  GetDineInOrderDetailsUseCase(this._repository);

  Future<DineInOrderEntity> call(String orderId) {
    return _repository.getOrderDetails(orderId);
  }
}
