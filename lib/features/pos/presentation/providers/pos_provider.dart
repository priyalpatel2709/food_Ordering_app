import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:food_order_app/core/di/providers.dart';
import 'package:food_order_app/features/menu/domain/entities/menu_entity.dart';
import 'package:food_order_app/features/menu/domain/usecases/get_all_menus_use_case.dart';
import 'package:food_order_app/features/menu/domain/usecases/get_current_menu_use_case.dart';
import 'package:food_order_app/features/order/domain/entities/order_entity.dart';
import 'package:food_order_app/features/order/presentation/providers/order_provider.dart';
import 'package:food_order_app/features/cart/domain/entities/cart_entity.dart';
import '../../../dine_in/domain/entities/payment_entity.dart';
import '../../../dine_in/presentation/providers/dine_in_providers.dart';
import '../../../dine_in/domain/entities/dine_in_order_entity.dart';
import '../../../dine_in/domain/usecases/create_dine_in_order_usecase.dart';
import '../../../dine_in/domain/usecases/add_items_to_dine_in_order_usecase.dart';
import '../../../dine_in/domain/usecases/complete_dine_in_payment_usecase.dart';
import '../../../dine_in/domain/usecases/get_order_details_usecase.dart';
import 'pos_state.dart';

final posNotifierProvider = StateNotifierProvider<PosNotifier, PosState>((ref) {
  final getAllMenus = ref.watch(getAllMenusUseCaseProvider);
  final getCurrentMenu = ref.watch(getCurrentMenuUseCaseProvider);
  final orderNotifier = ref.watch(orderNotifierProvider.notifier);
  final createDineInOrder = ref.watch(createDineInOrderUseCaseProvider);
  final addItemsToDineInOrder = ref.watch(addItemsToDineInOrderUseCaseProvider);
  final getDineInOrderDetails = ref.watch(getDineInOrderDetailsUseCaseProvider);
  final completeDineInPayment = ref.watch(completeDineInPaymentUseCaseProvider);

  return PosNotifier(
    getAllMenus: getAllMenus,
    getCurrentMenu: getCurrentMenu,
    orderNotifier: orderNotifier,
    createDineInOrder: createDineInOrder,
    addItemsToDineInOrder: addItemsToDineInOrder,
    getDineInOrderDetails: getDineInOrderDetails,
    completeDineInPayment: completeDineInPayment,
  );
});

class PosNotifier extends StateNotifier<PosState> {
  final GetAllMenusUseCase _getAllMenus;
  final GetCurrentMenuUseCase _getCurrentMenu;
  final OrderNotifier _orderNotifier;
  final CreateDineInOrderUseCase _createDineInOrder;
  final AddItemsToDineInOrderUseCase _addItemsToDineInOrder;
  final GetDineInOrderDetailsUseCase _getDineInOrderDetails;
  final CompleteDineInPaymentUseCase _completeDineInPayment;

  PosNotifier({
    required GetAllMenusUseCase getAllMenus,
    required GetCurrentMenuUseCase getCurrentMenu,
    required OrderNotifier orderNotifier,
    required CreateDineInOrderUseCase createDineInOrder,
    required AddItemsToDineInOrderUseCase addItemsToDineInOrder,
    required GetDineInOrderDetailsUseCase getDineInOrderDetails,
    required CompleteDineInPaymentUseCase completeDineInPayment,
  }) : _getAllMenus = getAllMenus,
       _getCurrentMenu = getCurrentMenu,
       _orderNotifier = orderNotifier,
       _createDineInOrder = createDineInOrder,
       _addItemsToDineInOrder = addItemsToDineInOrder,
       _getDineInOrderDetails = getDineInOrderDetails,
       _completeDineInPayment = completeDineInPayment,
       super(const PosState(categories: [], products: [])) {
    fetchProductsAndCategories();
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
  }) {
    // If we have customizations, we always add as a new item or find an exact match
    final existingIndex = state.cartItems.indexWhere(
      (item) =>
          item.menuItemId == product.id &&
          _areCustomizationsSame(item.selectedCustomizations, customizations),
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
  }

  void setCustomerName(String name) {
    state = state.copyWith(customerName: name);
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

    state = state.copyWith(isLoading: true);

    try {
      if (state.orderType == OrderType.dineIn && state.tableNumber != null) {
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
          );
        }).toList();

        if (state.ongoingOrderId != null) {
          // Add items to ongoing order
          await _addItemsToDineInOrder.call(state.ongoingOrderId!, dineInItems);

          // Refresh order details to show new items in "Ordered" section
          final order = await _getDineInOrderDetails.call(
            state.ongoingOrderId!,
          );
          state = state.copyWith(
            ongoingOrder: order,
            cartItems: [],
            isLoading: false,
          );
        } else {
          // Create new dine-in order
          final order = await _createDineInOrder.call(
            state.tableNumber!,
            items: dineInItems,
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
          customizationOptions: [],
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
      );

      await _orderNotifier.createOrder(request);
      state = state.copyWith(isLoading: false);
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
          );
        }).toList();
        await _addItemsToDineInOrder.call(orderId, dineInItems);
      }

      await _completeDineInPayment.call(orderId, paymentData);
      state = state.copyWith(
        isLoading: false,
        cartItems: [],
        ongoingOrderId: null,
        ongoingOrder: null,
        tableNumber: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
