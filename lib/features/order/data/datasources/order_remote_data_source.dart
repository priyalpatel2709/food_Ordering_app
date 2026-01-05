import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/order_entity.dart';

/// Remote data source for orders
abstract class OrderRemoteDataSource {
  Future<OrderEntity> createOrder(CreateOrderRequest request);
  Future<OrderEntity> getOrder(String orderId);
  Future<List<OrderEntity>> getOrders();
  Future<List<OrderEntity>> getMyOrders();
  Future<void> refundOrder(String orderId, double amount, String reason);
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
      queryParameters: {"sort":"-1"},
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

  @override
  Future<List<OrderEntity>> getMyOrders() async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.orders}${ApiConstants.myOrders}',
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] == 'success') {
      // The response has a nested structure: data.orders
      final ordersData = data['data'] as Map<String, dynamic>;
      final orders = (ordersData['orders'] as List)
          .map((order) => OrderEntity.fromJson(order as Map<String, dynamic>))
          .toList();
      return orders;
    } else {
      throw Exception(data['message'] ?? 'Failed to get my orders');
    }
  }

  @override
  Future<void> refundOrder(String orderId, double amount, String reason) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.payment}${ApiConstants.refund}/$orderId',
      data: {'amount': amount, 'reason': reason},
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Failed to refund order');
    }
  }
}
