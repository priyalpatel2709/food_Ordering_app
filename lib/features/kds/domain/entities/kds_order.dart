class KdsConfig {
  final List<String> workflow;

  const KdsConfig({required this.workflow});

  factory KdsConfig.fromJson(Map<String, dynamic> json) {
    return KdsConfig(workflow: List<String>.from(json['workflow'] ?? []));
  }
}

class KdsOrderItem {
  final String id;
  final String name;
  final int quantity;
  final String status;
  final Map<String, dynamic>? itemDetails;
  final List<String> modifiers;

  const KdsOrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.status,
    this.itemDetails,
    this.modifiers = const [],
  });

  factory KdsOrderItem.fromJson(Map<String, dynamic> json) {
    final itemData = json['item'];
    String name = 'Unknown Item';
    if (itemData is Map) {
      name = itemData['name'] ?? 'Unknown Item';
    } else if (json['name'] != null) {
      name = json['name'];
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
