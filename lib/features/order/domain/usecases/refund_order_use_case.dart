import '../../data/repositories/order_repository.dart';

class RefundOrderUseCase {
  final OrderRepository _repository;

  RefundOrderUseCase(this._repository);

  Future<void> call({
    required String orderId,
    required double amount,
    required String reason,
  }) {
    return _repository.refundOrder(orderId, amount, reason);
  }
}
