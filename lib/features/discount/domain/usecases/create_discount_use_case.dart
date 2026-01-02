import '../../data/repositories/discount_repository.dart';

class CreateDiscountUseCase {
  final DiscountRepository _repository;

  CreateDiscountUseCase(this._repository);

  Future<void> call(Map<String, dynamic> data) async {
    await _repository.createDiscount(data);
  }
}
