import '../../../cart/domain/entities/cart_entity.dart';
import '../../../menu/domain/entities/menu_entity.dart';
import '../../../dine_in/domain/entities/dine_in_order_entity.dart';
import '../../../order/domain/entities/order_type_entity.dart';

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
  final String? tableNumber;
  final String? ongoingOrderId;
  final DineInOrderEntity? ongoingOrder;
  final bool isLoading;
  final String? error;

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
    this.customerPhone,
    this.tableNumber,
    this.ongoingOrderId,
    this.ongoingOrder,
    this.isLoading = false,
    this.error,
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
    String? tableNumber,
    String? ongoingOrderId,
    DineInOrderEntity? ongoingOrder,
    bool? isLoading,
    String? error,
    bool clearSelectedCategory = false,
    bool clearOngoingOrderId = false,
    bool clearOngoingOrder = false,
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
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      tableNumber: tableNumber ?? this.tableNumber,
      ongoingOrderId: clearOngoingOrderId
          ? null
          : (ongoingOrderId ?? this.ongoingOrderId),
      ongoingOrder: clearOngoingOrder
          ? null
          : (ongoingOrder ?? this.ongoingOrder),
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
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
