import '../../domain/entities/order_entity.dart';
import '../datasources/order_remote_data_source.dart';

/// Order Repository Implementation
class OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepository(this._remoteDataSource);

  Future<OrderEntity> createOrder(CreateOrderRequest request) async {
    return await _remoteDataSource.createOrder(request);
  }

  Future<OrderEntity> getOrder(String orderId) async {
    return await _remoteDataSource.getOrder(orderId);
  }

  Future<List<OrderEntity>> getOrders() async {
    return await _remoteDataSource.getOrders();
  }

  Future<List<OrderEntity>> getMyOrders() async {
    return await _remoteDataSource.getMyOrders();
  }

  Future<void> refundOrder(String orderId, double amount, String reason) async {
    return await _remoteDataSource.refundOrder(orderId, amount, reason);
  }
}
