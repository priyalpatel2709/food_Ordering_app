/// Discount Entity
class DiscountEntity {
  final String? id;
  final String? restaurantId;
  final String? type; // 'percentage' or 'fixed'
  final String? discountCode;
  final double? value;
  final bool? isActive;
  final DateTime? validFrom;
  final DateTime? validTo;
  final List<dynamic>? metaData;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DiscountEntity({
    this.id,
    this.restaurantId,
    this.type,
    this.discountCode,
    this.value,
    this.isActive,
    this.validFrom,
    this.validTo,
    this.metaData,
    this.createdAt,
    this.updatedAt,
  });

  factory DiscountEntity.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('DiscountEntity.fromJson received null json');
    }

    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return DiscountEntity(
      id: json['_id']?.toString(),
      restaurantId: json['restaurantId']?.toString(),
      type: json['type']?.toString() ?? '',
      discountCode: json['discountCode']?.toString(),
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? false,
      validFrom: _parseDate(json['validFrom']),
      validTo: _parseDate(json['validTo']),
      metaData: json['metaData'] is List
          ? json['metaData'] as List<dynamic>
          : [],
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
    );
  }

  /// Check if discount is currently valid based on date range
  bool isValidNow() {
    if (!(isActive ?? true)) return false;

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
      return subtotal * ((value ?? 0) / 100);
    } else if (type == 'fixed') {
      return value ?? 0;
    }

    return 0.0;
  }
}
