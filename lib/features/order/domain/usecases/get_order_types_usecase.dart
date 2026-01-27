import '../entities/order_type_entity.dart';
import '../../data/repositories/order_repository.dart';

class GetOrderTypesUseCase {
  final OrderRepository _repository;

  GetOrderTypesUseCase(this._repository);

  Future<List<OrderTypeEntity>> call() async {
    return await _repository.getOrderTypes();
  }
}
