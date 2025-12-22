import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/order_entity.dart';

/// Remote data source for orders
abstract class OrderRemoteDataSource {
  Future<OrderEntity> createOrder(CreateOrderRequest request);
  Future<OrderEntity> getOrder(String orderId);
  Future<List<OrderEntity>> getOrders();
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient _dioClient;

  OrderRemoteDataSourceImpl(this._dioClient);

  @override
  Future<OrderEntity> createOrder(CreateOrderRequest request) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.orders}',
      data: request.toJson(),
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] == 'success') {
      return OrderEntity.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      throw Exception(data['message'] ?? 'Failed to create order');
    }
  }

  @override
  Future<OrderEntity> getOrder(String orderId) async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.orders}/$orderId',
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] == 'success') {
      return OrderEntity.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      throw Exception(data['message'] ?? 'Failed to get order');
    }
  }

  @override
  Future<List<OrderEntity>> getOrders() async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.orders}',
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] == 'success') {
      final orders = (data['data'] as List)
          .map((order) => OrderEntity.fromJson(order as Map<String, dynamic>))
          .toList();
      return orders;
    } else {
      throw Exception(data['message'] ?? 'Failed to get orders');
    }
  }
}
