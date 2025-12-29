/// Discount Entity
class DiscountEntity {
  final String id;
  final String restaurantId;
  final String type; // 'percentage' or 'fixed'
  final String discountCode;
  final double value;
  final bool isActive;
  final DateTime? validFrom;
  final DateTime? validTo;
  final List<dynamic> metaData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DiscountEntity({
    required this.id,
    required this.restaurantId,
    required this.type,
    required this.discountCode,
    required this.value,
    required this.isActive,
    this.validFrom,
    this.validTo,
    required this.metaData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiscountEntity.fromJson(Map<String, dynamic> json) {
    return DiscountEntity(
      id: json['_id'] as String,
      restaurantId: json['restaurantId'] as String,
      type: json['type'] as String,
      discountCode: json['discountCode'] as String,
      value: (json['value'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? false,
      validFrom: json['validFrom'] != null
          ? DateTime.parse(json['validFrom'] as String)
          : null,
      validTo: json['validTo'] != null
          ? DateTime.parse(json['validTo'] as String)
          : null,
      metaData: json['metaData'] as List<dynamic>? ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Check if discount is currently valid based on date range
  bool isValidNow() {
    if (!isActive) return false;

    final now = DateTime.now();

    if (validFrom != null && now.isBefore(validFrom!)) {
      return false;
    }

    if (validTo != null && now.isAfter(validTo!)) {
      return false;
    }

    return true;
  }

  /// Calculate discount amount based on subtotal
  double calculateDiscountAmount(double subtotal) {
    if (!isValidNow()) return 0.0;

    if (type == 'percentage') {
      return subtotal * (value / 100);
    } else if (type == 'fixed') {
      return value;
    }

    return 0.0;
  }
}
