import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_type_entity.dart';
import '../../domain/entities/create_order_with_payment_request.dart';
import '../../domain/entities/payment_process_request.dart';

/// Remote data source for orders
abstract class OrderRemoteDataSource {
  Future<OrderEntity> createOrder(CreateOrderRequest request);
  Future<OrderEntity> createOrderWithPayment(
    CreateOrderWithPaymentRequest request,
  );
  Future<OrderEntity> getOrder(String orderId);
  Future<List<OrderEntity>> getOrders();
  Future<List<OrderEntity>> getMyOrders();
  Future<List<OrderTypeEntity>> getOrderTypes();
  Future<void> cancelOrder(String orderId);
  Future<void> refundOrder(String orderId, double amount, String reason);
  Future<void> payOrder(String orderId, PaymentProcessRequest paymentData);
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
  Future<OrderEntity> createOrderWithPayment(
    CreateOrderWithPaymentRequest request,
  ) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.orders}/create-with-payment',
      data: request.toJson(),
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] == 'success') {
      return OrderEntity.fromJson(data['data'] as Map<String, dynamic>);
    } else {
      throw Exception(data['message'] ?? 'Failed to create order with payment');
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
      queryParameters: {"sort": "-1"},
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
  Future<List<OrderTypeEntity>> getOrderTypes() async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.orderTypeEndpoint}',
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] == 'success') {
      final list = (data['data'] as List)
          .map((item) => OrderTypeEntity.fromJson(item as Map<String, dynamic>))
          .toList();
      return list;
    } else {
      throw Exception(data['message'] ?? 'Failed to get order types');
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.orders}/cancel/$orderId',
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Failed to cancel order');
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

  @override
  Future<void> payOrder(
    String orderId,
    PaymentProcessRequest paymentData,
  ) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.payment}${ApiConstants.processPayment}/$orderId',
      data: paymentData.toJson(),
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Failed to pay order');
    }
  }
}
