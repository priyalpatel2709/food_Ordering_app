import '../repositories/dine_in_repository.dart';
import '../entities/dine_in_order_entity.dart';

class CreateDineInOrderUseCase {
  final DineInRepository _repository;

  CreateDineInOrderUseCase(this._repository);

  Future<DineInOrderEntity> call(
    String tableNumber, {
    List<DineInOrderItem>? items,
  }) {
    return _repository.createDineInOrder(tableNumber, items: items);
  }
}
