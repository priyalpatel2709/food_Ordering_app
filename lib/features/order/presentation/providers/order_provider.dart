import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../../data/repositories/order_repository.dart';
import '../../domain/entities/order_entity.dart';

/// Dio Client Provider
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// Order Remote Data Source Provider
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  return OrderRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

/// Order Repository Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(orderRemoteDataSourceProvider));
});

/// Order State
sealed class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderSuccess extends OrderState {
  final OrderEntity order;
  OrderSuccess(this.order);
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}

/// Orders List State (for multiple orders)
sealed class OrdersListState {}

class OrdersListInitial extends OrdersListState {}

class OrdersListLoading extends OrdersListState {}

class OrdersListSuccess extends OrdersListState {
  final List<OrderEntity> orders;
  OrdersListSuccess(this.orders);
}

class OrdersListError extends OrdersListState {
  final String message;
  OrdersListError(this.message);
}

/// Order Notifier
class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRepository _repository;

  OrderNotifier(this._repository) : super(OrderInitial());

  /// Create order
  Future<void> createOrder(CreateOrderRequest request) async {
    state = OrderLoading();
    try {
      final order = await _repository.createOrder(request);

      state = OrderSuccess(order);
    } catch (e,st) {
      log('order error: $e /n $st');
      state = OrderError(e.toString());
    }
  }

  /// Reset state
  void reset() {
    state = OrderInitial();
  }
}

/// Orders List Notifier
class OrdersListNotifier extends StateNotifier<OrdersListState> {
  final OrderRepository _repository;

  OrdersListNotifier(this._repository) : super(OrdersListInitial());

  /// Get my orders
  Future<void> getMyOrders() async {
    state = OrdersListLoading();
    try {
      final orders = await _repository.getMyOrders();
      state = OrdersListSuccess(orders);
    } catch (e) {
      log('get my orders error: $e');
      state = OrdersListError(e.toString());
    }
  }

  /// Reset state
  void reset() {
    state = OrdersListInitial();
  }
}

/// Order Notifier Provider
final orderNotifierProvider = StateNotifierProvider<OrderNotifier, OrderState>((
  ref,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrderNotifier(repository);
});

/// Orders List Notifier Provider
final ordersListNotifierProvider =
    StateNotifierProvider<OrdersListNotifier, OrdersListState>((ref) {
      final repository = ref.watch(orderRepositoryProvider);
      return OrdersListNotifier(repository);
    });
