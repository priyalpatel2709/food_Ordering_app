class OrderTypeEntity {
  final String id;
  final String restaurantId;
  final String orderType;
  final bool isActive;

  const OrderTypeEntity({
    required this.id,
    required this.restaurantId,
    required this.orderType,
    required this.isActive,
  });

  factory OrderTypeEntity.fromJson(Map<String, dynamic> json) {
    return OrderTypeEntity(
      id: json['_id'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      orderType: json['orderType'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantId': restaurantId,
      'orderType': orderType,
      'isActive': isActive,
    };
  }
}
