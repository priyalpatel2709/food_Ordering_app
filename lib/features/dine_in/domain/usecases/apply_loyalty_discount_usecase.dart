import '../repositories/dine_in_repository.dart';

class ApplyLoyaltyDiscountUseCase {
  final DineInRepository _repository;

  ApplyLoyaltyDiscountUseCase(this._repository);

  Future<void> call({
    required String orderId,
    required String loyaltyCustomerId,
    required int pointsToRedeem,
  }) async {
    return await _repository.applyLoyaltyDiscountToOrder(
      orderId: orderId,
      loyaltyCustomerId: loyaltyCustomerId,
      pointsToRedeem: pointsToRedeem,
    );
  }
}
