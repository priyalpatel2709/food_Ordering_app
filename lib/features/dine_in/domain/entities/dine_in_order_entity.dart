class DineInModifier {
  final String name;
  final double price;

  const DineInModifier({required this.name, required this.price});

  factory DineInModifier.fromJson(Map<String, dynamic> json) {
    return DineInModifier(
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'price': price};
  }
}

class DineInOrderItem {
  final String id; // Unique ID for this order item entry
  final String itemId; // ID of the menu item
  final String name;
  final int quantity;
  final double price;
  final List<DineInModifier> modifiers;
  final String? specialInstructions;
  final String status;

  const DineInOrderItem({
    required this.id,
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.price,
    this.modifiers = const [],
    this.specialInstructions,
    this.status = 'new',
  });

  factory DineInOrderItem.fromJson(Map<String, dynamic> json) {
    // Handle both populated item object and simple ID
    final itemData = json['item'];
    String itemId = '';
    String? itemName;

    if (itemData is Map) {
      itemId = itemData['_id'] ?? itemData['id'] ?? '';
      itemName = itemData['name'];
    } else {
      itemId = itemData?.toString() ?? '';
      itemName = json['name'];
    }

    return DineInOrderItem(
      id: json['_id'] ?? json['id'] ?? '',
      itemId: itemId,
      name: itemName ?? 'Unknown Item',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      status: json['status'] ?? json['itemStatus'] ?? 'new',
      modifiers:
          (json['modifiers'] as List<dynamic>?)
              ?.map((e) => DineInModifier.fromJson(e))
              .toList() ??
          [],
      specialInstructions: json['specialInstructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'modifiers': modifiers.map((e) => e.toJson()).toList(),
    };
  }
}

class DineInOrderEntity {
  final String id;
  final String tableNumber;
  final String status;
  final List<DineInOrderItem> items;
  final double totalAmount;

  const DineInOrderEntity({
    required this.id,
    required this.tableNumber,
    required this.status,
    required this.items,
    required this.totalAmount,
  });

  factory DineInOrderEntity.fromJson(Map<String, dynamic> json) {
    return DineInOrderEntity(
      id: json['_id'] ?? json['id'] ?? '',
      tableNumber: json['tableNumber'] ?? '',
      status: json['orderStatus'] ?? json['status'] ?? 'confirmed',
      items:
          ((json['orderItems'] ?? json['items']) as List<dynamic>?)
              ?.map((e) => DineInOrderItem.fromJson(e))
              .toList() ??
          [],
      totalAmount:
          (json['orderFinalCharge'] ??
                  json['subtotal'] ??
                  json['totalAmount'] ??
                  0)
              .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'status': status,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
    };
  }
}
