import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:food_order_app/core/di/providers.dart';
import 'package:food_order_app/features/menu/domain/entities/menu_entity.dart';
import 'package:food_order_app/features/menu/domain/usecases/get_all_menus_use_case.dart';
import 'package:food_order_app/features/menu/domain/usecases/get_current_menu_use_case.dart';
import 'package:food_order_app/features/order/domain/entities/order_entity.dart';
import 'package:food_order_app/features/order/domain/entities/create_order_with_payment_request.dart';
import 'package:food_order_app/features/order/presentation/providers/order_provider.dart';
import 'package:food_order_app/features/order/domain/usecases/get_order_types_usecase.dart';
import 'package:food_order_app/features/cart/domain/entities/cart_entity.dart';
import '../../../dine_in/domain/entities/payment_entity.dart';
import '../../../dine_in/presentation/providers/dine_in_providers.dart';
import '../../../dine_in/domain/entities/dine_in_order_entity.dart';
import '../../../dine_in/domain/usecases/create_dine_in_order_usecase.dart';
import '../../../dine_in/domain/usecases/add_items_to_dine_in_order_usecase.dart';
import '../../../dine_in/domain/usecases/complete_dine_in_payment_usecase.dart';
import '../../../dine_in/domain/usecases/get_order_details_usecase.dart';
import '../../domain/entities/held_order.dart';
import '../../../loyalty/domain/entities/customer_loyalty_entity.dart';
import '../../../loyalty/presentation/providers/loyalty_providers.dart';
import '../../../loyalty/domain/usecases/loyalty_usecases.dart';
import 'pos_state.dart';

final posNotifierProvider = StateNotifierProvider<PosNotifier, PosState>((ref) {
  final getAllMenus = ref.watch(getAllMenusUseCaseProvider);
  final getCurrentMenu = ref.watch(getCurrentMenuUseCaseProvider);
  final orderNotifier = ref.watch(orderNotifierProvider.notifier);
  final createDineInOrder = ref.watch(createDineInOrderUseCaseProvider);
  final addItemsToDineInOrder = ref.watch(addItemsToDineInOrderUseCaseProvider);
  final getDineInOrderDetails = ref.watch(getDineInOrderDetailsUseCaseProvider);
  final completeDineInPayment = ref.watch(completeDineInPaymentUseCaseProvider);
  final getOrderTypes = ref.watch(getOrderTypesUseCaseProvider);
  final redeemPoints = ref.watch(redeemPointsUseCaseProvider);

  return PosNotifier(
    ref: ref,
    getAllMenus: getAllMenus,
    getCurrentMenu: getCurrentMenu,
    orderNotifier: orderNotifier,
    createDineInOrder: createDineInOrder,
    addItemsToDineInOrder: addItemsToDineInOrder,
    getDineInOrderDetails: getDineInOrderDetails,
    completeDineInPayment: completeDineInPayment,
    getOrderTypes: getOrderTypes,
    redeemPoints: redeemPoints,
  );
});

class PosNotifier extends StateNotifier<PosState> {
  final Ref _ref;
  final GetAllMenusUseCase _getAllMenus;
  final GetCurrentMenuUseCase _getCurrentMenu;
  final OrderNotifier _orderNotifier;
  final CreateDineInOrderUseCase _createDineInOrder;
  final AddItemsToDineInOrderUseCase _addItemsToDineInOrder;
  final GetDineInOrderDetailsUseCase _getDineInOrderDetails;
  final CompleteDineInPaymentUseCase _completeDineInPayment;
  final GetOrderTypesUseCase _getOrderTypes;
  final RedeemPointsUseCase _redeemPoints;

  PosNotifier({
    required Ref ref,
    required GetAllMenusUseCase getAllMenus,
    required GetCurrentMenuUseCase getCurrentMenu,
    required OrderNotifier orderNotifier,
    required CreateDineInOrderUseCase createDineInOrder,
    required AddItemsToDineInOrderUseCase addItemsToDineInOrder,
    required GetDineInOrderDetailsUseCase getDineInOrderDetails,
    required CompleteDineInPaymentUseCase completeDineInPayment,
    required GetOrderTypesUseCase getOrderTypes,
    required RedeemPointsUseCase redeemPoints,
  }) : _ref = ref,
       _getAllMenus = getAllMenus,
       _getCurrentMenu = getCurrentMenu,
       _orderNotifier = orderNotifier,
       _createDineInOrder = createDineInOrder,
       _addItemsToDineInOrder = addItemsToDineInOrder,
       _getDineInOrderDetails = getDineInOrderDetails,
       _completeDineInPayment = completeDineInPayment,
       _getOrderTypes = getOrderTypes,
       _redeemPoints = redeemPoints,
       super(const PosState(categories: [], products: [])) {
    _init();
  }

  Future<void> _init() async {
    await fetchOrderTypes();
    await fetchProductsAndCategories();
  }

  Future<void> fetchOrderTypes() async {
    try {
      final types = await _getOrderTypes.call();
      state = state.copyWith(availableOrderTypes: types);

      // Set default dynamic order type based on current orderType enum
      _syncDynamicOrderType();
    } catch (e) {
      log('Error fetching order types: $e');
    }
  }

  void _syncDynamicOrderType() {
    if (state.availableOrderTypes.isEmpty) return;

    final typeName = switch (state.orderType) {
      OrderType.dineIn => 'Dine_In',
      OrderType.takeaway => 'Take_away',
      OrderType.delivery => 'Delivery',
    };

    final dynamicType = state.availableOrderTypes.firstWhere(
      (t) => t.orderType.toLowerCase() == typeName.toLowerCase(),
      orElse: () => state.availableOrderTypes.first,
    );

    state = state.copyWith(dynamicOrderType: dynamicType);
  }

  Future<void> fetchProductsAndCategories({String? menuId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final menusResult = await _getAllMenus.call(page: 1, limit: 100);
      final currentMenuResult = await _getCurrentMenu.execute(menuId: menuId);

      menusResult.when(
        success: (menusData) {
          final allMenus = menusData.items;
          currentMenuResult.when(
            success: (currentMenuData) {
              final activeMenu = currentMenuData.isNotEmpty
                  ? currentMenuData.first
                  : (allMenus.isNotEmpty ? allMenus.first : null);

              if (activeMenu != null) {
                state = state.copyWith(
                  availableMenus: allMenus,
                  selectedMenu: activeMenu,
                  categories: activeMenu.categories,
                  products: activeMenu.items,
                  selectedCategory: null,
                  isLoading: false,
                );
              } else {
                state = state.copyWith(
                  availableMenus: allMenus,
                  isLoading: false,
                  error: "No active menu found",
                );
              }
            },
            failure: (error) {
              state = state.copyWith(isLoading: false, error: error.message);
            },
          );
        },
        failure: (error) {
          state = state.copyWith(isLoading: false, error: error.message);
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectMenu(MenuEntity menu) async {
    // log('menu selected ${menu.name} ${menu.id}');
    await fetchProductsAndCategories(menuId: menu.id);
    // state = state.copyWith(
    //   selectedMenu: menu,
    //   categories: menu.categories,
    //   products: menu.items,
    //   selectedCategory: null,
    // );
  }

  void selectCategory(CategoryEntity? category) {
    if (category?.id == 'all') {
      state = state.copyWith(selectedCategory: null);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void addToCart(
    MenuItemEntity product, {
    List<CustomizationSelection> customizations = const [],
    String? note,
  }) {
    // If we have customizations, we always add as a new item or find an exact match
    final existingIndex = state.cartItems.indexWhere(
      (item) =>
          item.menuItemId == product.id &&
          _areCustomizationsSame(item.selectedCustomizations, customizations) &&
          item.note == note,
    );

    if (existingIndex >= 0) {
      incrementQuantity(state.cartItems[existingIndex].id);
    } else {
      final newItem = CartItemEntity(
        id: const Uuid().v4(),
        menuItemId: product.id,
        menuItemName: product.name,
        menuItemImage: product.image,
        basePrice: product.price,
        quantity: 1,
        selectedCustomizations: customizations,
        addedAt: DateTime.now(),
        taxRate: product.taxRate,
        note: note,
      );
      state = state.copyWith(cartItems: [...state.cartItems, newItem]);
    }
  }

  bool _areCustomizationsSame(
    List<CustomizationSelection> a,
    List<CustomizationSelection> b,
  ) {
    if (a.length != b.length) return false;
    final aIds = a.map((e) => e.id).toList()..sort();
    final bIds = b.map((e) => e.id).toList()..sort();
    for (int i = 0; i < aIds.length; i++) {
      if (aIds[i] != bIds[i]) return false;
    }
    return true;
  }

  void incrementQuantity(String cartItemId) {
    state = state.copyWith(
      cartItems: [
        for (final item in state.cartItems)
          if (item.id == cartItemId)
            item.copyWith(quantity: item.quantity + 1)
          else
            item,
      ],
    );
  }

  void decrementQuantity(String cartItemId) {
    final item = state.cartItems.firstWhere((i) => i.id == cartItemId);
    if (item.quantity > 1) {
      state = state.copyWith(
        cartItems: [
          for (final i in state.cartItems)
            if (i.id == cartItemId) i.copyWith(quantity: i.quantity - 1) else i,
        ],
      );
    } else {
      removeItem(cartItemId);
    }
  }

  void removeItem(String cartItemId) {
    state = state.copyWith(
      cartItems: state.cartItems.where((i) => i.id != cartItemId).toList(),
    );
  }

  void clearCart() {
    state = state.copyWith(cartItems: []);
  }

  void setOrderType(OrderType type) {
    state = state.copyWith(orderType: type);
    _syncDynamicOrderType();
  }

  void setCustomerName(String name) {
    state = state.copyWith(customerName: name);
  }

  void setScheduledOrder(DateTime? date, String? time) {
    state = state.copyWith(scheduledFor: date, scheduledOrderTime: time);
  }

  void clearScheduledOrder() {
    state = state.copyWith(clearScheduledOrder: true);
  }

  void setLoyaltyCustomer(CustomerLoyaltyEntity? customer) {
    state = state.copyWith(
      loyaltyCustomer: customer,
      customerName: customer?.name ?? state.customerName,
      customerPhone: customer?.phone ?? state.customerPhone,
      customerId: customer?.id ?? state.customerId,
      clearLoyaltyCustomer: customer == null,
    );
  }

  void applyLoyaltyDiscount(double amount, int points) {
    state = state.copyWith(loyaltyDiscount: amount, redeemedPoints: points);
  }

  void clearLoyalty() {
    state = state.copyWith(
      clearLoyaltyCustomer: true,
      loyaltyDiscount: 0.0,
      redeemedPoints: 0,
    );
  }

  /// Hold/Park the current order
  void holdCurrentOrder() {
    if (state.cartItems.isEmpty) return;

    final heldOrder = HeldOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(state.cartItems),
      orderType: state.orderType,
      customerName: state.customerName,
      customerId: state.customerId,
      tableNumber: state.tableNumber,
      loyaltyCustomer: state.loyaltyCustomer,
      heldAt: DateTime.now(),
      totalAmount: state.summary.total,
      loyaltyDiscount: state.loyaltyDiscount,
      redeemedPoints: state.redeemedPoints,
    );

    final updatedHeldOrders = [...state.heldOrders, heldOrder];

    state = state.copyWith(
      heldOrders: updatedHeldOrders,
      cartItems: [],
      customerName: null,
      customerId: null,
      tableNumber: null,
      clearOngoingOrderId: true,
      clearOngoingOrder: true,
      loyaltyDiscount: 0.0,
      redeemedPoints: 0,
      clearLoyaltyCustomer: true,
    );
  }

  /// Retrieve a held order back to the cart
  void retrieveHeldOrder(String heldOrderId) {
    final heldOrder = state.heldOrders.firstWhere(
      (order) => order.id == heldOrderId,
    );

    final updatedHeldOrders = state.heldOrders
        .where((order) => order.id != heldOrderId)
        .toList();

    state = state.copyWith(
      cartItems: List.from(heldOrder.items),
      orderType: heldOrder.orderType,
      customerName: heldOrder.customerName,
      customerId: heldOrder.customerId,
      loyaltyCustomer: heldOrder.loyaltyCustomer,
      tableNumber: heldOrder.tableNumber,
      heldOrders: updatedHeldOrders,
      loyaltyDiscount: heldOrder.loyaltyDiscount,
      redeemedPoints: heldOrder.redeemedPoints,
    );
  }

  /// Remove a held order without retrieving it
  void removeHeldOrder(String heldOrderId) {
    final updatedHeldOrders = state.heldOrders
        .where((order) => order.id != heldOrderId)
        .toList();

    state = state.copyWith(heldOrders: updatedHeldOrders);
  }

  void selectTable(String? tableNumber, {String? orderId}) async {
    state = state.copyWith(
      tableNumber: tableNumber,
      ongoingOrderId: orderId,
      orderType: OrderType.dineIn,
      clearOngoingOrder: true,
      clearOngoingOrderId: orderId == null,
    );

    if (orderId != null) {
      try {
        final order = await _getDineInOrderDetails.call(orderId);
        state = state.copyWith(ongoingOrder: order);
      } catch (e) {
        state = state.copyWith(error: 'Failed to load order: $e');
      }
    }
  }

  Future<void> placeOrder() async {
    if (state.cartItems.isEmpty) return;

    if (state.orderType == OrderType.dineIn && state.tableNumber == null) {
      state = state.copyWith(error: 'Please select a table for Dine-In order');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      if (state.orderType == OrderType.dineIn) {
        final dineInItems = state.cartItems.map((cartItem) {
          return DineInOrderItem(
            id: cartItem.id,
            itemId: cartItem.menuItemId,
            name: cartItem.menuItemName,
            price: cartItem.basePrice,
            quantity: cartItem.quantity,
            status: 'new',
            modifiers: cartItem.selectedCustomizations
                .map((m) => DineInModifier(name: m.name, price: m.price))
                .toList(),
            specialInstructions: cartItem.note,
          );
        }).toList();

        if (state.ongoingOrderId != null && state.ongoingOrderId!.isNotEmpty) {
          // Add items to ongoing order
          final order = await _addItemsToDineInOrder.call(
            state.ongoingOrderId!,
            dineInItems,
          );

          state = state.copyWith(
            ongoingOrderId: order.id,
            ongoingOrder: order,
            cartItems: [],
            isLoading: false,
          );
        } else {
          // Create new dine-in order
          final order = await _createDineInOrder.call(
            state.tableNumber!,
            items: dineInItems,
            orderTypeId: state.dynamicOrderType?.id,
            customerId: state.customerId, //make changes
          );
          state = state.copyWith(
            ongoingOrderId: order.id,
            ongoingOrder: order,
            cartItems: [],
            isLoading: false,
          );
        }
        return;
      }

      // Default order creation (Takeaway/Delivery or Dine-in without table)
      final summary = state.summary;
      final orderItems = summary.items.map((cartItem) {
        return OrderItemRequest(
          item: cartItem.menuItemId,
          quantity: cartItem.quantity,
          price: cartItem.basePrice,
          customizationOptions: cartItem.selectedCustomizations
              .map((m) => DineInModifier(name: m.name, price: m.price))
              .toList(),
        );
      }).toList();

      // Collect unique tax IDs
      final taxIds = summary.items
          .where((item) => item.taxRate != null)
          .map((item) => item.taxRate!.id)
          .toSet()
          .toList();

      final request = CreateOrderRequest(
        orderItems: orderItems,
        tax: taxIds,
        discount: [],
        restaurantTipCharge: 0,
        deliveryCharge: state.orderType == OrderType.delivery ? 5.0 : 0.0,
        deliveryTipCharge: 0,
        orderType: state.dynamicOrderType?.id ?? '',
        scheduledFor: state.scheduledFor,
        isScheduledOrder: state.scheduledOrderTime != null,
        contactPhone: state.customerPhone,
        contactEmail: state.loyaltyCustomer?.email,
        contactName: state.customerName,
        customerId: state.customerId,
        loyaltyDiscount: state.loyaltyDiscount > 0
            ? state.loyaltyDiscount
            : null,
        pointsRedeemed: state.redeemedPoints > 0 ? state.redeemedPoints : null,
      );

      await _orderNotifier.createOrder(request);

      // Handle point redemption if applicable for Takeaway/Delivery
      if (state.loyaltyCustomer != null && state.redeemedPoints > 0) {
        try {
          await _redeemPoints.call(
            state.loyaltyCustomer!.id,
            state.redeemedPoints,
          );
        } catch (e) {
          log('Warning: Loyalty points redemption failed: $e');
        }
      }

      // Invalidate staff orders list to refresh order history
      _ref.invalidate(staffOrdersListNotifierProvider);

      state = state.copyWith(
        isLoading: false,
        cartItems: [],
        clearScheduledOrder: true,
        clearLoyaltyCustomer: true,
        clearCustomerInfo: true,
        loyaltyDiscount: 0.0,
        redeemedPoints: 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Place order with payment (for Takeaway/Delivery orders)
  Future<void> placeOrderWithPayment(PaymentEntity paymentData) async {
    if (state.cartItems.isEmpty) return;

    if (state.orderType == OrderType.dineIn) {
      state = state.copyWith(error: 'Use Place Order for dine-in, then Settle');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final summary = state.summary;
      final orderItems = summary.items.map((cartItem) {
        return OrderItemRequest(
          item: cartItem.menuItemId,
          quantity: cartItem.quantity,
          price: cartItem.basePrice,
          customizationOptions: cartItem.selectedCustomizations
              .map((m) => DineInModifier(name: m.name, price: m.price))
              .toList(),
        );
      }).toList();

      // Collect unique tax IDs
      final taxIds = summary.items
          .where((item) => item.taxRate != null)
          .map((item) => item.taxRate!.id)
          .toSet()
          .toList();

      final paymentDataObj = PaymentData(
        method: paymentData.payment.method,
        amount: paymentData.payment.amount,
        notes: paymentData.payment.notes,
        cashRegisterId: paymentData.payment.cashRegisterId,
        // transactionId: paymentData.payment.transactionId, // If you have it
      );

      final request = CreateOrderWithPaymentRequest(
        orderItems: orderItems,
        tax: taxIds,
        discount: [],
        restaurantTipCharge: 0,
        deliveryCharge: state.orderType == OrderType.delivery ? 5.0 : 0.0,
        deliveryTipCharge: 0,
        orderType: state.dynamicOrderType?.id ?? '',
        scheduledDeliveryTime: state.scheduledFor,
        isScheduledOrder: state.scheduledOrderTime != null,
        contactPhone: paymentData.customerPhone ?? state.customerPhone ?? '',
        contactEmail: paymentData.customerEmail ?? state.loyaltyCustomer?.email,
        contactName: paymentData.customerName ?? state.customerName,
        customerId: state.customerId,
        // Pass validation directly to backend via request
        loyaltyCustomerId: state.loyaltyCustomer?.id,
        pointsToRedeem: state.redeemedPoints > 0 ? state.redeemedPoints : null,
        payment: paymentDataObj,
      );

      log('Sending CreateOrderWithPaymentRequest: ${request.toJson()}');

      await _orderNotifier.createOrderWithPayment(request);

      // No need to manually redeem points as the backend handles it via create-with-payment

      // Invalidate staff orders list to refresh order history
      _ref.invalidate(staffOrdersListNotifierProvider);

      state = state.copyWith(
        isLoading: false,
        cartItems: [],
        clearScheduledOrder: true,
        clearLoyaltyCustomer: true,
        clearCustomerInfo: true,
        loyaltyDiscount: 0.0,
        redeemedPoints: 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> settleOrder(String orderId, PaymentEntity paymentData) async {
    state = state.copyWith(isLoading: true);
    try {
      // If there are pending items in cart, add them first
      if (state.cartItems.isNotEmpty) {
        final dineInItems = state.cartItems.map((cartItem) {
          return DineInOrderItem(
            id: cartItem.id,
            itemId: cartItem.menuItemId,
            name: cartItem.menuItemName,
            price: cartItem.basePrice,
            quantity: cartItem.quantity,
            status: 'new',
            modifiers: cartItem.selectedCustomizations
                .map((m) => DineInModifier(name: m.name, price: m.price))
                .toList(),
            specialInstructions: cartItem.note,
          );
        }).toList();
        await _addItemsToDineInOrder.call(orderId, dineInItems);
      }

      await _completeDineInPayment.call(orderId, paymentData);

      // Handle point redemption if applicable
      if (state.loyaltyCustomer != null && state.redeemedPoints > 0) {
        try {
          await _redeemPoints.call(
            state.loyaltyCustomer!.id,
            state.redeemedPoints,
          );
        } catch (e) {
          log('Warning: Loyalty points redemption failed: $e');
          // We continue anyway as the payment succeeded
        }
      }

      // Invalidate tables, order details and staff orders list to refresh UI across the app
      _ref.invalidate(tablesProvider);
      _ref.invalidate(orderDetailsProvider(orderId));
      _ref.invalidate(staffOrdersListNotifierProvider);

      state = state.copyWith(
        isLoading: false,
        cartItems: [],
        clearOngoingOrderId: true,
        clearOngoingOrder: true,
        clearTableNumber: true,
        clearLoyaltyCustomer: true,
        clearCustomerInfo: true,
        loyaltyDiscount: 0.0,
        redeemedPoints: 0,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
