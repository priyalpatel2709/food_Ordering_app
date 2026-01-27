class PaymentEntity {
  final Payment payment;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerName;

  PaymentEntity({
    required this.payment,
    this.customerPhone,
    this.customerEmail,
    this.customerName,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'payment': payment.toMap()};
    if (customerPhone != null) map['customerPhone'] = customerPhone!;
    if (customerEmail != null) map['customerEmail'] = customerEmail!;
    if (customerName != null) map['customerName'] = customerName!;
    return map;
  }

  Map<String, dynamic> toJson() => toMap();
}

class Payment {
  final String method;
  final double amount;
  final String? notes;
  final Discount? discount;

  Payment({
    required this.method,
    required this.amount,
    this.notes,
    this.discount,
  });

  Map<String, dynamic> toMap() {
    return {
      'method': method,
      'amount': amount,
      'notes': notes,
      'discount': discount?.toMap(),
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

class Discount {
  final List<DiscountDetails?>? discounts;
  final double? totalDiscountAmount;

  Discount({this.discounts, this.totalDiscountAmount});

  Map<String, dynamic> toMap() {
    return {
      'discounts': discounts?.map((e) => e?.toMap()).toList(),
      'totalDiscountAmount': totalDiscountAmount,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

class DiscountDetails {
  final String? discountId;
  final double? discountAmount;
  final String? discountType; // "loyalty_points" or "manual"
  final int? pointsRedeemed;

  DiscountDetails({
    this.discountId,
    this.discountAmount,
    this.discountType,
    this.pointsRedeemed,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'discountId': discountId,
      'discountAmount': discountAmount,
    };
    if (discountType != null) map['discountType'] = discountType;
    if (pointsRedeemed != null) map['pointsRedeemed'] = pointsRedeemed;
    return map;
  }

  Map<String, dynamic> toJson() => toMap();
}
