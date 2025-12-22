import '../../../menu/domain/entities/menu_entity.dart';

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
  final TaxRateEntity? taxRate; // Tax rate for this item (e.g., 0.1 for 10%)

  const CartItemEntity({
    required this.id,
    required this.menuItemId,
    required this.menuItemName,
    required this.menuItemImage,
    required this.basePrice,
    required this.quantity,
    required this.selectedCustomizations,
    required this.addedAt,
    this.taxRate, // Default 10% tax
  });

  /// Get price per item (base + customizations)
  double get pricePerItem {
    final customizationTotal = selectedCustomizations.fold<double>(
      0,
      (sum, customization) => sum + customization.price,
    );
    return basePrice + customizationTotal;
  }

  /// Get tax per item
  double get taxPerItem {
    if (taxRate == null) return 0.0;
    // TaxRateEntity.percentage is in percentage (e.g., 10 for 10%)
    // Convert to decimal by dividing by 100
    return pricePerItem * (taxRate!.percentage / 100);
  }

  /// Get total price with tax per item
  double get pricePerItemWithTax {
    return pricePerItem + taxPerItem;
  }

  /// Calculate total price for this cart item (price + tax) * quantity
  double get totalPrice {
    return pricePerItemWithTax * quantity;
  }

  /// Get total tax for this cart item
  double get totalTax {
    return taxPerItem * quantity;
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
    TaxRateEntity? taxRate,
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
      taxRate: taxRate ?? this.taxRate,
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
  final double subtotal; // Total before tax
  final double totalTax; // Sum of all item taxes
  final double total; // Subtotal + tax
  final int totalItems;

  const CartSummary({
    required this.items,
    required this.subtotal,
    required this.totalTax,
    required this.total,
    required this.totalItems,
  });

  factory CartSummary.fromItems(List<CartItemEntity> items) {
    // Calculate subtotal (price without tax)
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + (item.pricePerItem * item.quantity),
    );

    // Calculate total tax (sum of all item taxes)
    final totalTax = items.fold<double>(0, (sum, item) => sum + item.totalTax);

    // Total = subtotal + tax
    final total = subtotal + totalTax;

    final totalItems = items.fold<int>(0, (sum, item) => sum + item.quantity);

    return CartSummary(
      items: items,
      subtotal: subtotal,
      totalTax: totalTax,
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
