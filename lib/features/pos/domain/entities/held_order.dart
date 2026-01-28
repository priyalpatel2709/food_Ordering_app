import '../../../cart/domain/entities/cart_entity.dart';
import '../../presentation/providers/pos_state.dart';
import '../../../loyalty/domain/entities/customer_loyalty_entity.dart';

/// Represents a held/parked order in the POS system
class HeldOrder {
  final String id;
  final List<CartItemEntity> items;
  final OrderType orderType;
  final String? customerName;
  final String? customerId;
  final String? tableNumber;
  final CustomerLoyaltyEntity? loyaltyCustomer;
  final DateTime heldAt;
  final double totalAmount;
  final double loyaltyDiscount;
  final int redeemedPoints;

  const HeldOrder({
    required this.id,
    required this.items,
    required this.orderType,
    this.customerName,
    this.customerId,
    this.tableNumber,
    this.loyaltyCustomer,
    required this.heldAt,
    required this.totalAmount,
    this.loyaltyDiscount = 0.0,
    this.redeemedPoints = 0,
  });

  HeldOrder copyWith({
    String? id,
    List<CartItemEntity>? items,
    OrderType? orderType,
    String? customerName,
    String? customerId,
    String? tableNumber,
    CustomerLoyaltyEntity? loyaltyCustomer,
    DateTime? heldAt,
    double? totalAmount,
    double? loyaltyDiscount,
    int? redeemedPoints,
  }) {
    return HeldOrder(
      id: id ?? this.id,
      items: items ?? this.items,
      orderType: orderType ?? this.orderType,
      customerName: customerName ?? this.customerName,
      customerId: customerId ?? this.customerId,
      tableNumber: tableNumber ?? this.tableNumber,
      loyaltyCustomer: loyaltyCustomer ?? this.loyaltyCustomer,
      heldAt: heldAt ?? this.heldAt,
      totalAmount: totalAmount ?? this.totalAmount,
      loyaltyDiscount: loyaltyDiscount ?? this.loyaltyDiscount,
      redeemedPoints: redeemedPoints ?? this.redeemedPoints,
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
