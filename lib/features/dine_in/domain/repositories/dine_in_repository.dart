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
}
