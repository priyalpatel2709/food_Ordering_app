enum TableStatus { available, occupied, ongoing }

class TableEntity {
  final String id;
  final String tableNumber;
  final TableStatus status;
  final int capacity;
  final String? currentOrderId;

  const TableEntity({
    required this.id,
    required this.tableNumber,
    required this.status,
    required this.capacity,
    this.currentOrderId,
  });

  factory TableEntity.fromJson(Map<String, dynamic> json) {
    return TableEntity(
      id: json['_id'] ?? json['id'] ?? '',
      tableNumber: json['tableNumber'] ?? '',
      status: TableStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == json['status']?.toString().toLowerCase(),
        orElse: () => TableStatus.available,
      ),
      capacity: json['capacity'] ?? 0,
      currentOrderId: _parseOrderId(json),
    );
  }

  static String? _parseOrderId(Map<String, dynamic> json) {
    final orderData =
        json['orderId'] ;
    if (orderData == null) return null;
    if (orderData is String) return orderData;
    if (orderData is Map) return orderData['_id'] ?? orderData['id'];
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'status': status.name,
      'capacity': capacity,
      'orderId': currentOrderId,
    };
  }
}
