import '../../../cart/domain/entities/cart_entity.dart';
import '../../presentation/providers/pos_state.dart';

/// Represents a held/parked order in the POS system
class HeldOrder {
  final String id;
  final List<CartItemEntity> items;
  final OrderType orderType;
  final String? customerName;
  final String? customerId;
  final String? tableNumber;
  final DateTime heldAt;
  final double totalAmount;

  const HeldOrder({
    required this.id,
    required this.items,
    required this.orderType,
    this.customerName,
    this.customerId,
    this.tableNumber,
    required this.heldAt,
    required this.totalAmount,
  });

  HeldOrder copyWith({
    String? id,
    List<CartItemEntity>? items,
    OrderType? orderType,
    String? customerName,
    String? customerId,
    String? tableNumber,
    DateTime? heldAt,
    double? totalAmount,
  }) {
    return HeldOrder(
      id: id ?? this.id,
      items: items ?? this.items,
      orderType: orderType ?? this.orderType,
      customerName: customerName ?? this.customerName,
      customerId: customerId ?? this.customerId,
      tableNumber: tableNumber ?? this.tableNumber,
      heldAt: heldAt ?? this.heldAt,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  String get displayName {
    if (customerName != null && customerName!.isNotEmpty) {
      return customerName!;
    }
    if (tableNumber != null && tableNumber!.isNotEmpty) {
      return 'Table $tableNumber';
    }
    return 'Order #${id.substring(0, 8)}';
  }
}
