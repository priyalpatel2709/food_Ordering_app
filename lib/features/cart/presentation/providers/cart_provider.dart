import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_entity.dart';

/// Cart State
sealed class CartState {
  const CartState();
}

class CartEmpty extends CartState {
  const CartEmpty();
}

class CartLoaded extends CartState {
  final CartSummary summary;

  const CartLoaded(this.summary);

  List<CartItemEntity> get items => summary.items;
  bool get isEmpty => summary.isEmpty;
  bool get isNotEmpty => summary.isNotEmpty;
}

/// Cart Notifier
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartEmpty());

  final List<CartItemEntity> _items = [];

  /// Add item to cart
  void addItem({
    required String menuItemId,
    required String menuItemName,
    required String menuItemImage,
    required double basePrice,
    required List<CustomizationSelection> selectedCustomizations,
  }) {
    // Generate unique ID based on item and customizations
    final customizationIds = selectedCustomizations.map((c) => c.id).toList()
      ..sort();
    final uniqueId = '$menuItemId-${customizationIds.join("-")}';

    // Check if item with same customizations already exists
    final existingIndex = _items.indexWhere((item) => item.id == uniqueId);

    if (existingIndex != -1) {
      // Increment quantity
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      // Add new item
      _items.add(
        CartItemEntity(
          id: uniqueId,
          menuItemId: menuItemId,
          menuItemName: menuItemName,
          menuItemImage: menuItemImage,
          basePrice: basePrice,
          quantity: 1,
          selectedCustomizations: selectedCustomizations,
          addedAt: DateTime.now(),
        ),
      );
    }

    _updateState();
  }

  /// Update item quantity
  void updateQuantity(String cartItemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(cartItemId);
      return;
    }

    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: newQuantity);
      _updateState();
    }
  }

  /// Increment item quantity
  void incrementQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + 1,
      );
      _updateState();
    }
  }

  /// Decrement item quantity
  void decrementQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      final currentQuantity = _items[index].quantity;
      if (currentQuantity > 1) {
        _items[index] = _items[index].copyWith(quantity: currentQuantity - 1);
        _updateState();
      } else {
        removeItem(cartItemId);
      }
    }
  }

  /// Remove item from cart
  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    _updateState();
  }

  /// Clear all items from cart
  void clearCart() {
    _items.clear();
    state = const CartEmpty();
  }

  /// Get cart item count
  int get itemCount => _items.fold<int>(0, (sum, item) => sum + item.quantity);

  /// Get total price
  double get totalPrice =>
      _items.fold<double>(0, (sum, item) => sum + item.totalPrice);

  /// Update state
  void _updateState() {
    if (_items.isEmpty) {
      state = const CartEmpty();
    } else {
      state = CartLoaded(CartSummary.fromItems(_items));
    }
  }
}

/// Cart Provider
final cartNotifierProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);

/// Cart item count provider
final cartItemCountProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartNotifierProvider);
  if (cartState is CartLoaded) {
    return cartState.summary.totalItems;
  }
  return 0;
});
