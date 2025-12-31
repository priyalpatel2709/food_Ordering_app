import '../../domain/repositories/dine_in_repository.dart';
import '../../domain/entities/dine_in_order_entity.dart';
import '../../domain/entities/table_entity.dart';
import '../datasources/dine_in_remote_datasource.dart';

class DineInRepositoryImpl implements DineInRepository {
  final DineInRemoteDataSource _remoteDataSource;

  DineInRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TableEntity>> getTables() async {
    return await _remoteDataSource.getTables();
  }

  @override
  Future<DineInOrderEntity> createDineInOrder(
    String tableNumber, {
    List<DineInOrderItem>? items,
  }) async {
    return await _remoteDataSource.createDineInOrder(tableNumber, items: items);
  }

  @override
  Future<DineInOrderEntity> addItemsToOrder(
    String orderId,
    List<DineInOrderItem> items,
  ) async {
    return await _remoteDataSource.addItemsToOrder(orderId, items);
  }

  @override
  Future<void> completePayment(
    String orderId,
    Map<String, dynamic> paymentDetails,
  ) async {
    await _remoteDataSource.completePayment(orderId, paymentDetails);
  }

  @override
  Future<DineInOrderEntity> getOrderDetails(String orderId) async {
    return await _remoteDataSource.getOrderDetails(orderId);
  }

  @override
  Future<void> deleteDineInOrder(String orderId) async {
    await _remoteDataSource.deleteDineInOrder(orderId);
  }

  @override
  Future<DineInOrderEntity> deleteDineInOrderItem(
    String orderId,
    String itemId,
  ) async {
    return await _remoteDataSource.deleteDineInOrderItem(orderId, itemId);
  }
}
