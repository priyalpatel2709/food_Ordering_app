import '../../data/repositories/discount_repository.dart';

class DeleteDiscountUseCase {
  final DiscountRepository _repository;

  DeleteDiscountUseCase(this._repository);

  Future<void> call(String id) async {
    await _repository.deleteDiscount(id);
  }
}
