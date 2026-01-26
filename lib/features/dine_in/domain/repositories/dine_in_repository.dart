import '../entities/dine_in_order_entity.dart';
import '../entities/table_entity.dart';

abstract class DineInRepository {
  Future<List<TableEntity>> getTables();
  Future<DineInOrderEntity> createDineInOrder(
    String tableNumber, {
    List<DineInOrderItem>? items,
  });
  Future<DineInOrderEntity> addItemsToOrder(
    String orderId,
    List<DineInOrderItem> items,
  );
  Future<void> completePayment(
    String orderId,
    Map<String, dynamic> paymentDetails,
  );
  Future<DineInOrderEntity> getOrderDetails(String orderId);
  Future<void> deleteDineInOrder(String orderId);
  Future<DineInOrderEntity> deleteDineInOrderItem(
    String orderId,
    String itemId,
  );

  // Table CRUD
  Future<TableEntity> createTable(String tableNumber, int capacity);
  Future<TableEntity> updateTable(
    String id,
    String tableNumber,
    int capacity,
    TableStatus status,
  );
  Future<void> deleteTable(String id);
}
