class KdsConfig {
  final List<String> workflow;
  final Map<String, List<String>>
  stations; // Station Name -> List of Categories

  const KdsConfig({required this.workflow, required this.stations});

  factory KdsConfig.fromJson(Map<String, dynamic> json) {
    // Parse stations
    final stationsMap = <String, List<String>>{};
    if (json['stations'] is List) {
      // Handle list format if backend sends array of objects
      for (final s in json['stations']) {
        if (s is Map) {
          final name = s['name'] as String? ?? 'Unknown';
          final categories =
              (s['categories'] as List?)?.map((e) => e.toString()).toList() ??
              [];
          stationsMap[name] = categories;
        }
      }
    } else if (json['stations'] is Map) {
      // Handle map format
      (json['stations'] as Map<String, dynamic>).forEach((key, value) {
        if (value is List) {
          stationsMap[key] = value.map((e) => e.toString()).toList();
        }
      });
    }

    return KdsConfig(
      workflow: List<String>.from(json['workflow'] ?? []),
      stations: stationsMap,
    );
  }
}

class KdsOrderItem {
  final String id;
  final String name;
  final int quantity;
  final String status;
  final String? category; // Category ID or Name
  final Map<String, dynamic>? itemDetails;
  final List<String> modifiers;

  const KdsOrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.status,
    this.category,
    this.itemDetails,
    this.modifiers = const [],
  });

  factory KdsOrderItem.fromJson(Map<String, dynamic> json) {
    final itemData = json['item'];
    String name = 'Unknown Item';
    String? category;

    if (itemData is Map) {
      name = itemData['name'] ?? 'Unknown Item';
      // Assuming itemData has category object or ID
      if (itemData['category'] is Map) {
        category = itemData['category']['name'];
      } else if (itemData['category'] is String) {
        category = itemData['category'];
      }
    } else if (json['name'] != null) {
      name = json['name'];
    }

    // Fallback if category is top-level in order item
    if (category == null && json['category'] != null) {
      if (json['category'] is Map) {
        category = json['category']['name'];
      } else {
        category = json['category'].toString();
      }
    }

    final modifiersData = json['modifiers'] as List<dynamic>?;
    final modifiers =
        modifiersData
            ?.map((m) {
              if (m is Map) return m['name']?.toString() ?? '';
              return m.toString();
            })
            .where((m) => m.isNotEmpty)
            .toList() ??
        [];

    return KdsOrderItem(
      id: json['_id'] ?? json['id'] ?? '',
      name: name,
      quantity: json['quantity'] ?? 1,
      status: json['status'] ?? json['itemStatus'] ?? 'new',
      category: category,
      itemDetails: itemData is Map ? itemData as Map<String, dynamic> : null,
      modifiers: modifiers,
    );
  }
}

class KdsOrder {
  final String id;
  final String orderId; // printable ID
  final String? tableNumber;
  final String kdsStatus;
  final List<KdsOrderItem> items;
  final DateTime createdAt;

  const KdsOrder({
    required this.id,
    required this.orderId,
    this.tableNumber,
    required this.kdsStatus,
    required this.items,
    required this.createdAt,
  });

  factory KdsOrder.fromJson(Map<String, dynamic> json) {
    return KdsOrder(
      id: json['_id'] ?? json['id'] ?? '',
      orderId: json['orderId'] ?? '',
      tableNumber: json['tableNumber'],
      kdsStatus: json['kdsStatus'] ?? 'new',
      items:
          (json['orderItems'] as List<dynamic>?)
              ?.map((e) => KdsOrderItem.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
