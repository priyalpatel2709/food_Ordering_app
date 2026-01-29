import 'order_entity.dart';

/// Request to create order with payment in one API call
class CreateOrderWithPaymentRequest {
  final List<OrderItemRequest> orderItems;
  final List<String> tax;
  final List<String> discount;
  final double restaurantTipCharge;
  final double deliveryCharge;
  final double deliveryTipCharge;
  final String orderType;
  final String contactPhone;
  final String? contactEmail;
  final String? contactName;
  final String? customerId;
  final String? loyaltyCustomerId;
  final int? pointsToRedeem;
  final PaymentData payment;
  final DeliveryAddress? deliveryAddress;
  final bool? isScheduledOrder;
  final DateTime? scheduledDeliveryTime;
  final String? orderNote;
  final String? serverName;

  const CreateOrderWithPaymentRequest({
    required this.orderItems,
    this.tax = const [],
    this.discount = const [],
    this.restaurantTipCharge = 0,
    this.deliveryCharge = 0,
    this.deliveryTipCharge = 0,
    required this.orderType,
    required this.contactPhone,
    this.contactEmail,
    this.contactName,
    this.customerId,
    this.loyaltyCustomerId,
    this.pointsToRedeem,
    required this.payment,
    this.deliveryAddress,
    this.isScheduledOrder,
    this.scheduledDeliveryTime,
    this.orderNote,
    this.serverName,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'tax': tax,
      'discount': discount,
      'restaurantTipCharge': restaurantTipCharge,
      'deliveryCharge': deliveryCharge,
      'deliveryTipCharge': deliveryTipCharge,
      'orderType': orderType,
      'contactPhone': contactPhone,
      'payment': payment.toJson(),
    };

    if (contactEmail != null) json['contactEmail'] = contactEmail!;
    if (contactName != null) json['contactName'] = contactName!;
    if (customerId != null) json['customerId'] = customerId!;
    if (loyaltyCustomerId != null)
      json['loyaltyCustomerId'] = loyaltyCustomerId!;
    if (pointsToRedeem != null) json['pointsToRedeem'] = pointsToRedeem!;
    if (deliveryAddress != null)
      json['deliveryAddress'] = deliveryAddress!.toJson();
    if (isScheduledOrder != null) json['isScheduledOrder'] = isScheduledOrder!;
    if (scheduledDeliveryTime != null) {
      json['scheduledDeliveryTime'] = scheduledDeliveryTime!.toIso8601String();
    }
    if (orderNote != null) json['orderNote'] = orderNote!;
    if (serverName != null) json['serverName'] = serverName!;

    return json;
  }
}

/// Payment data for create-with-payment endpoint
class PaymentData {
  final String method; // cash, credit, debit, upi, online, wallet
  final double amount;
  final String? transactionId;
  final String? gateway;
  final String? notes;
  final String? cashRegisterId;

  const PaymentData({
    required this.method,
    required this.amount,
    this.transactionId,
    this.gateway,
    this.notes,
    this.cashRegisterId,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'method': method, 'amount': amount};

    if (transactionId != null) json['transactionId'] = transactionId!;
    if (gateway != null) json['gateway'] = gateway!;
    if (notes != null) json['notes'] = notes!;
    if (cashRegisterId != null) json['cashRegisterId'] = cashRegisterId!;

    return json;
  }
}

/// Delivery address for orders
class DeliveryAddress {
  final String street;
  final String city;
  final String state;
  final String zip;
  final Coordinates? coordinates;

  const DeliveryAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    this.coordinates,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'street': street,
      'city': city,
      'state': state,
      'zip': zip,
    };

    if (coordinates != null) json['coordinates'] = coordinates!.toJson();

    return json;
  }
}

/// GPS coordinates
class Coordinates {
  final double lat;
  final double lng;

  const Coordinates({required this.lat, required this.lng});

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}
