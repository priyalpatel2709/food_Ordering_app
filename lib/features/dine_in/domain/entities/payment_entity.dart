class PaymentEntity {
  final Payment payment;

  PaymentEntity({required this.payment});

  Map<String, dynamic> toMap() {
    return {'payment': payment.toMap()};
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

  DiscountDetails({this.discountId, this.discountAmount});

  Map<String, dynamic> toMap() {
    return {'discountId': discountId, 'discountAmount': discountAmount};
  }

  Map<String, dynamic> toJson() => toMap();
}
