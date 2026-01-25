import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:food_order_app/core/di/providers.dart';
import 'package:food_order_app/features/menu/domain/entities/menu_entity.dart';
import 'package:food_order_app/features/menu/domain/usecases/get_all_items_use_case.dart';
import 'package:food_order_app/features/menu/domain/usecases/get_all_categories_use_case.dart';
import 'package:food_order_app/features/order/domain/entities/order_entity.dart';
import 'package:food_order_app/features/order/presentation/providers/order_provider.dart';
import 'package:food_order_app/features/cart/domain/entities/cart_entity.dart';
import 'pos_state.dart';

final posNotifierProvider = StateNotifierProvider<PosNotifier, PosState>((ref) {
  final getAllItems = ref.watch(getAllItemsUseCaseProvider);
  final getAllCategories = ref.watch(getAllCategoriesUseCaseProvider);
  final orderNotifier = ref.watch(orderNotifierProvider.notifier);

  return PosNotifier(
    getAllItems: getAllItems,
    getAllCategories: getAllCategories,
    orderNotifier: orderNotifier,
  );
});

class PosNotifier extends StateNotifier<PosState> {
  final GetAllItemsUseCase _getAllItems;
  final GetAllCategoriesUseCase _getAllCategories;
  final OrderNotifier _orderNotifier;

  PosNotifier({
    required GetAllItemsUseCase getAllItems,
    required GetAllCategoriesUseCase getAllCategories,
    required OrderNotifier orderNotifier,
  }) : _getAllItems = getAllItems,
       _getAllCategories = getAllCategories,
       _orderNotifier = orderNotifier,
       super(const PosState(categories: [], products: [])) {
    fetchProductsAndCategories();
  }

  Future<void> fetchProductsAndCategories() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final categoriesResult = await _getAllCategories(page: 1, limit: 100);
      final itemsResult = await _getAllItems(page: 1, limit: 100);

      categoriesResult.when(
        success: (categoriesData) {
          itemsResult.when(
            success: (itemsData) {
              state = state.copyWith(
                categories: categoriesData.items,
                products: itemsData.items,
                selectedCategory: null, // Default to 'All'
                isLoading: false,
              );
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

  void addToCart(MenuItemEntity product) {
    final existingIndex = state.cartItems.indexWhere(
      (item) => item.menuItemId == product.id,
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
        selectedCustomizations: [],
        addedAt: DateTime.now(),
        taxRate: product.taxRate,
      );
      state = state.copyWith(cartItems: [...state.cartItems, newItem]);
    }
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

  Future<void> placeOrder() async {
    if (state.cartItems.isEmpty) return;

    state = state.copyWith(isLoading: true);

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
  }
}
