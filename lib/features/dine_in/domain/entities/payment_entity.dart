class PaymentEntity {
  final Payment payment;

  PaymentEntity({required this.payment});
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
}

class Discount {
  final List<DiscountDetails?>? discounts;
  final double? totalDiscountAmount;

  Discount({this.discounts, this.totalDiscountAmount});
}

class DiscountDetails {
  final String? discountId;
  final double? discountAmount;

  DiscountDetails({this.discountId, this.discountAmount});
}
