import '../entities/dine_in_order_entity.dart';
import '../repositories/dine_in_repository.dart';

class RemoveDineInItemUseCase {
  final DineInRepository _repository;

  RemoveDineInItemUseCase(this._repository);

  Future<DineInOrderEntity> call(String orderId, String itemId) async {
    return await _repository.deleteDineInOrderItem(orderId, itemId);
  }
}
