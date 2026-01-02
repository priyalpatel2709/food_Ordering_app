import '../../data/repositories/discount_repository.dart';

class UpdateDiscountUseCase {
  final DiscountRepository _repository;

  UpdateDiscountUseCase(this._repository);

  Future<void> call(String id, Map<String, dynamic> data) async {
    await _repository.updateDiscount(id, data);
  }
}
