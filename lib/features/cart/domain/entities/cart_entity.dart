/// Cart Item Entity
class CartItemEntity {
  final String id; // Unique ID for cart item
  final String menuItemId;
  final String menuItemName;
  final String menuItemImage;
  final double basePrice;
  final int quantity;
  final List<CustomizationSelection> selectedCustomizations;
  final DateTime addedAt;

  const CartItemEntity({
    required this.id,
    required this.menuItemId,
    required this.menuItemName,
    required this.menuItemImage,
    required this.basePrice,
    required this.quantity,
    required this.selectedCustomizations,
    required this.addedAt,
  });

  /// Calculate total price for this cart item (base + customizations) * quantity
  double get totalPrice {
    final customizationTotal = selectedCustomizations.fold<double>(
      0,
      (sum, customization) => sum + customization.price,
    );
    return (basePrice + customizationTotal) * quantity;
  }

  /// Get price per item (base + customizations)
  double get pricePerItem {
    final customizationTotal = selectedCustomizations.fold<double>(
      0,
      (sum, customization) => sum + customization.price,
    );
    return basePrice + customizationTotal;
  }

  CartItemEntity copyWith({
    String? id,
    String? menuItemId,
    String? menuItemName,
    String? menuItemImage,
    double? basePrice,
    int? quantity,
    List<CustomizationSelection>? selectedCustomizations,
    DateTime? addedAt,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      menuItemId: menuItemId ?? this.menuItemId,
      menuItemName: menuItemName ?? this.menuItemName,
      menuItemImage: menuItemImage ?? this.menuItemImage,
      basePrice: basePrice ?? this.basePrice,
      quantity: quantity ?? this.quantity,
      selectedCustomizations:
          selectedCustomizations ?? this.selectedCustomizations,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  String toString() =>
      'CartItemEntity(id: $id, name: $menuItemName, quantity: $quantity, total: \$${totalPrice.toStringAsFixed(2)})';
}

/// Customization Selection
class CustomizationSelection {
  final String id;
  final String name;
  final double price;

  const CustomizationSelection({
    required this.id,
    required this.name,
    required this.price,
  });

  CustomizationSelection copyWith({String? id, String? name, double? price}) {
    return CustomizationSelection(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomizationSelection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CustomizationSelection(id: $id, name: $name, price: \$${price.toStringAsFixed(2)})';
}

/// Cart Summary
class CartSummary {
  final List<CartItemEntity> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final int totalItems;

  const CartSummary({
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.totalItems,
  });

  factory CartSummary.fromItems(List<CartItemEntity> items) {
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final tax = subtotal * 0.1; // 10% tax
    final deliveryFee = subtotal > 0 ? 5.0 : 0.0; // $5 delivery fee
    final total = subtotal + tax + deliveryFee;
    final totalItems = items.fold<int>(0, (sum, item) => sum + item.quantity);

    return CartSummary(
      items: items,
      subtotal: subtotal,
      tax: tax,
      deliveryFee: deliveryFee,
      total: total,
      totalItems: totalItems,
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  @override
  String toString() =>
      'CartSummary(items: ${items.length}, total: \$${total.toStringAsFixed(2)})';
}
