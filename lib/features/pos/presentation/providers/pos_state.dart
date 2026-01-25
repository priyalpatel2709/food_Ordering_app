import '../../../cart/domain/entities/cart_entity.dart';
import '../../../menu/domain/entities/menu_entity.dart';

enum OrderType { dineIn, takeaway, delivery }

class PosState {
  final List<CategoryEntity> categories;
  final List<MenuItemEntity> products;
  final CategoryEntity? selectedCategory;
  final String searchQuery;
  final List<CartItemEntity> cartItems;
  final OrderType orderType;
  final String? customerName;
  final bool isLoading;
  final String? error;

  const PosState({
    required this.categories,
    required this.products,
    this.selectedCategory,
    this.searchQuery = '',
    this.cartItems = const [],
    this.orderType = OrderType.dineIn,
    this.customerName,
    this.isLoading = false,
    this.error,
  });

  PosState copyWith({
    List<CategoryEntity>? categories,
    List<MenuItemEntity>? products,
    CategoryEntity? selectedCategory,
    String? searchQuery,
    List<CartItemEntity>? cartItems,
    OrderType? orderType,
    String? customerName,
    bool? isLoading,
    String? error,
  }) {
    return PosState(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      cartItems: cartItems ?? this.cartItems,
      orderType: orderType ?? this.orderType,
      customerName: customerName ?? this.customerName,
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
