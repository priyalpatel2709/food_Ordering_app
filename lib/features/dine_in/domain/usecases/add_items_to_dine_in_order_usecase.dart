import '../repositories/dine_in_repository.dart';
import '../entities/dine_in_order_entity.dart';

class AddItemsToDineInOrderUseCase {
  final DineInRepository _repository;

  AddItemsToDineInOrderUseCase(this._repository);

  Future<DineInOrderEntity> call(String orderId, List<DineInOrderItem> items) {
    return _repository.addItemsToOrder(orderId, items);
  }
}
