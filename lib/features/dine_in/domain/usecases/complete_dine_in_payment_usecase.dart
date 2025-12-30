import '../repositories/dine_in_repository.dart';

class CompleteDineInPaymentUseCase {
  final DineInRepository _repository;

  CompleteDineInPaymentUseCase(this._repository);

  Future<void> call(String orderId, Map<String, dynamic> paymentDetails) {
    return _repository.completePayment(orderId, paymentDetails);
  }
}
