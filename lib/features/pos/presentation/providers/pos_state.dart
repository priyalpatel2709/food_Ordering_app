import '../../../cart/domain/entities/cart_entity.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import '../../../dine_in/domain/entities/dine_in_order_entity.dart';
import '../../../order/domain/entities/order_type_entity.dart';
import '../../domain/entities/held_order.dart';
import '../../../loyalty/domain/entities/customer_loyalty_entity.dart';

enum OrderType { dineIn, takeaway, delivery }

class PosState {
  final List<MenuEntity> availableMenus;
  final MenuEntity? selectedMenu;
  final List<CategoryEntity> categories;
  final List<MenuItemEntity> products;
  final CategoryEntity? selectedCategory;
  final String searchQuery;
  final List<CartItemEntity> cartItems;
  final OrderType orderType;
  final List<OrderTypeEntity> availableOrderTypes;
  final OrderTypeEntity? dynamicOrderType; // Selected dynamic order type
  final String? customerName;
  final String? customerPhone;
  final String? customerId;
  final String? tableNumber;
  final String? ongoingOrderId;
  final DineInOrderEntity? ongoingOrder;
  final bool isLoading;
  final String? error;
  final DateTime? scheduledFor; // Scheduled date for the order
  final String? scheduledOrderTime; // Scheduled time in HH:mm format
  final List<HeldOrder> heldOrders; // List of held/parked orders
  final CustomerLoyaltyEntity? loyaltyCustomer; // Selected loyalty customer
  final double loyaltyDiscount; // Discount amount applied from points
  final int redeemedPoints; // Total points redeemed for this order

  const PosState({
    this.availableMenus = const [],
    this.selectedMenu,
    required this.categories,
    required this.products,
    this.selectedCategory,
    this.searchQuery = '',
    this.cartItems = const [],
    this.orderType = OrderType.dineIn,
    this.availableOrderTypes = const [],
    this.dynamicOrderType,
    this.customerName,
    this.customerId,
    this.customerPhone,
    this.tableNumber,
    this.ongoingOrderId,
    this.ongoingOrder,
    this.isLoading = false,
    this.error,
    this.scheduledFor,
    this.scheduledOrderTime,
    this.heldOrders = const [],
    this.loyaltyCustomer,
    this.loyaltyDiscount = 0.0,
    this.redeemedPoints = 0,
  });

  PosState copyWith({
    List<MenuEntity>? availableMenus,
    MenuEntity? selectedMenu,
    List<CategoryEntity>? categories,
    List<MenuItemEntity>? products,
    CategoryEntity? selectedCategory,
    String? searchQuery,
    List<CartItemEntity>? cartItems,
    OrderType? orderType,
    List<OrderTypeEntity>? availableOrderTypes,
    OrderTypeEntity? dynamicOrderType,
    String? customerName,
    String? customerPhone,
    String? customerId,
    String? tableNumber,
    String? ongoingOrderId,
    DineInOrderEntity? ongoingOrder,
    bool? isLoading,
    String? error,
    DateTime? scheduledFor,
    String? scheduledOrderTime,
    List<HeldOrder>? heldOrders,
    CustomerLoyaltyEntity? loyaltyCustomer,
    double? loyaltyDiscount,
    int? redeemedPoints,
    bool clearSelectedCategory = false,
    bool clearOngoingOrderId = false,
    bool clearOngoingOrder = false,
    bool clearScheduledOrder = false,
    bool clearLoyaltyCustomer = false,
    bool clearCustomerInfo = false,
    bool clearTableNumber = false,
  }) {
    return PosState(
      availableMenus: availableMenus ?? this.availableMenus,
      selectedMenu: selectedMenu ?? this.selectedMenu,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      cartItems: cartItems ?? this.cartItems,
      orderType: orderType ?? this.orderType,
      availableOrderTypes: availableOrderTypes ?? this.availableOrderTypes,
      dynamicOrderType: dynamicOrderType ?? this.dynamicOrderType,
      customerName: clearCustomerInfo
          ? null
          : (customerName ?? this.customerName),

      customerId: clearCustomerInfo ? null : (customerId ?? this.customerId),

      customerPhone: clearCustomerInfo
          ? null
          : (customerPhone ?? this.customerPhone),
      tableNumber: clearTableNumber ? null : (tableNumber ?? this.tableNumber),
      ongoingOrderId: clearOngoingOrderId
          ? null
          : (ongoingOrderId ?? this.ongoingOrderId),
      ongoingOrder: clearOngoingOrder
          ? null
          : (ongoingOrder ?? this.ongoingOrder),
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      scheduledFor: clearScheduledOrder
          ? null
          : (scheduledFor ?? this.scheduledFor),
      scheduledOrderTime: clearScheduledOrder
          ? null
          : (scheduledOrderTime ?? this.scheduledOrderTime),
      heldOrders: heldOrders ?? this.heldOrders,
      loyaltyCustomer: clearLoyaltyCustomer
          ? null
          : (loyaltyCustomer ?? this.loyaltyCustomer),
      loyaltyDiscount: loyaltyDiscount ?? this.loyaltyDiscount,
      redeemedPoints: redeemedPoints ?? this.redeemedPoints,
    );
  }

  List<MenuItemEntity> get filteredProducts {
    var filtered = products;
    if (selectedCategory != null) {
      filtered = filtered
          .where((p) => p.category.id == selectedCategory!.id)
          .toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }
    return filtered;
  }

  CartSummary get summary => CartSummary.fromItems(cartItems);
}
