import '../repositories/dine_in_repository.dart';

class RemoveDineInOrderUseCase {
  final DineInRepository _repository;

  RemoveDineInOrderUseCase(this._repository);

  Future<void> call(String orderId) async {
    return await _repository.deleteDineInOrder(orderId);
  }
}
