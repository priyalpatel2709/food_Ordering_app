import '../../../dine_in/domain/entities/dine_in_order_entity.dart';

/// Order Item Entity for API request
class OrderItemRequest {
  final String item; // Menu item ID
  final int quantity;
  final double price;
  final List<DineInModifier> customizationOptions;

  const OrderItemRequest({
    required this.item,
    required this.quantity,
    required this.price,
    required this.customizationOptions,
  });

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'quantity': quantity,
      'price': price,
      'customizationOptions': customizationOptions,
    };
  }
}

/// Create Order Request
class CreateOrderRequest {
  final List<OrderItemRequest> orderItems;
  final List<String> tax; // Tax IDs
  final List<String> discount; // Discount IDs
  final double restaurantTipCharge;
  final double deliveryCharge;
  final double deliveryTipCharge;
  // final String restaurantId;

  const CreateOrderRequest({
    required this.orderItems,
    this.tax = const [],
    this.discount = const [],
    this.restaurantTipCharge = 0,
    this.deliveryCharge = 0,
    this.deliveryTipCharge = 0,
    // required this.restaurantId,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'tax': tax,
      'discount': discount,
      'restaurantTipCharge': restaurantTipCharge,
      'deliveryCharge': deliveryCharge,
      'deliveryTipCharge': deliveryTipCharge,
      // 'restaurantId': restaurantId,
    };
  }
}

/// Tax Breakdown
class TaxBreakdown {
  final String taxId;
  final double taxCharge;

  const TaxBreakdown({required this.taxId, required this.taxCharge});

  factory TaxBreakdown.fromJson(Map<String, dynamic> json) {
    return TaxBreakdown(
      taxId: json['taxId'] as String,
      taxCharge: (json['taxCharge'] as num).toDouble(),
    );
  }
}

/// Discount Breakdown
class DiscountBreakdown {
  final String discountId;
  final double discountAmount;

  const DiscountBreakdown({
    required this.discountId,
    required this.discountAmount,
  });

  factory DiscountBreakdown.fromJson(Map<String, dynamic> json) {
    return DiscountBreakdown(
      discountId: json['discountId'] as String,
      discountAmount: (json['discountAmount'] as num).toDouble(),
    );
  }
}

/// Order Response Entity
class OrderEntity {
  final String id;
  final String orderId;
  final String restaurantId;
  final String customerId;
  final double restaurantTipCharge;
  final bool isScheduledOrder;
  final bool isDeliveryOrder;
  final double deliveryTipCharge;
  final double deliveryCharge;
  final double subtotal;
  final TaxInfo tax;
  final DiscountInfo discount;
  final double orderFinalCharge;
  final PaymentInfo payment;
  final String orderStatus;
  final int totalItemCount;
  final List<OrderItemEntity> orderItems;
  final List<dynamic> statusHistory;
  final List<dynamic> metaData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.orderId,
    required this.restaurantId,
    required this.customerId,
    required this.restaurantTipCharge,
    required this.isScheduledOrder,
    required this.isDeliveryOrder,
    required this.deliveryTipCharge,
    required this.deliveryCharge,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.orderFinalCharge,
    required this.payment,
    required this.orderStatus,
    required this.totalItemCount,
    required this.orderItems,
    required this.statusHistory,
    required this.metaData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    return OrderEntity(
      id: json['_id'] as String,
      orderId: json['orderId'] as String,
      restaurantId: json['restaurantId'].toString(), // Convert to string
      customerId: json['customerId'] as String,
      restaurantTipCharge:
          (json['restaurantTipCharge'] as num?)?.toDouble() ?? 0.0,
      isScheduledOrder: json['isScheduledOrder'] as bool? ?? false,
      isDeliveryOrder: json['isDeliveryOrder'] as bool? ?? false,
      deliveryTipCharge: (json['deliveryTipCharge'] as num?)?.toDouble() ?? 0.0,
      deliveryCharge: (json['deliveryCharge'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: TaxInfo.fromJson(json['tax'] as Map<String, dynamic>),
      discount: DiscountInfo.fromJson(json['discount'] as Map<String, dynamic>),
      orderFinalCharge: (json['orderFinalCharge'] as num).toDouble(),
      payment: PaymentInfo.fromJson(json['payment'] as Map<String, dynamic>),
      orderStatus: json['orderStatus'] as String,
      totalItemCount: json['totalItemCount'] as int,
      orderItems: (json['orderItems'] as List)
          .map((item) => OrderItemEntity.fromJson(item))
          .toList(),
      statusHistory: json['statusHistory'] as List<dynamic>? ?? [],
      metaData: json['metaData'] as List<dynamic>? ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Helper getter for total tax amount
  double get totalTaxAmount => tax.totalTaxAmount;

  // Helper getter for total discount amount
  double get totalDiscountAmount => discount.totalDiscountAmount;
}

/// Menu Item Details within Order Item
class MenuItem {
  final String? id;
  final String? restaurantId;
  final String? category;
  final String? name;
  final String? description;
  final double? price;
  final String? image;
  final bool? isAvailable;
  final int? preparationTime;
  final List<String>? allergens;
  final List<String>? customizationOptions;
  final int? popularityScore;
  final double? averageRating;
  final bool? taxable;
  final List<String>? taxRate;
  final int? minOrderQuantity;
  final int? maxOrderQuantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MenuItem({
    this.id,
    this.restaurantId,
    this.category,
    this.name,
    this.description,
    this.price,
    this.image,
    this.isAvailable,
    this.preparationTime,
    this.allergens,
    this.customizationOptions,
    this.popularityScore,
    this.averageRating,
    this.taxable,
    this.taxRate,
    this.minOrderQuantity,
    this.maxOrderQuantity,
    this.createdAt,
    this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['_id'] as String,
      restaurantId: json['restaurantId'],
      category: json['category'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      image: json['image'],
      isAvailable: json['isAvailable'] as bool? ?? true,
      preparationTime: json['preparationTime'],
      allergens: (json['allergens'] as List).cast<String>(),
      customizationOptions: (json['customizationOptions']).cast<String>(),
      popularityScore: json['popularityScore'],
      averageRating: (json['averageRating']).toDouble(),
      taxable: json['taxable'] as bool? ?? false,
      taxRate: (json['taxRate'] as List).cast<String>(),
      minOrderQuantity: json['minOrderQuantity'],
      maxOrderQuantity: json['maxOrderQuantity'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class OrderItemEntity {
  final String id;
  final MenuItem item;
  final int quantity;
  final double price;
  final double discountPrice;
  final List<dynamic> modifiers;

  const OrderItemEntity({
    required this.id,
    required this.item,
    required this.quantity,
    required this.price,
    required this.discountPrice,
    required this.modifiers,
  });

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    return OrderItemEntity(
      id: json['_id'] as String,
      item: MenuItem.fromJson(json['item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discountPrice'] as num?)?.toDouble() ?? 0.0,
      modifiers: json['modifiers'] as List<dynamic>? ?? [],
    );
  }
}

/// Tax Info
class TaxInfo {
  final List<TaxBreakdown> taxes;
  final double totalTaxAmount;

  const TaxInfo({required this.taxes, required this.totalTaxAmount});

  factory TaxInfo.fromJson(Map<String, dynamic> json) {
    return TaxInfo(
      taxes: (json['taxes'] as List)
          .map((item) => TaxBreakdown.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalTaxAmount: (json['totalTaxAmount'] as num).toDouble(),
    );
  }
}

class PaymentInfo {
  final double totalPaid;
  final double balanceDue;
  final String paymentStatus;
  final List<dynamic> history;

  const PaymentInfo({
    required this.totalPaid,
    required this.balanceDue,
    required this.paymentStatus,
    required this.history,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      totalPaid: (json['totalPaid'] as num).toDouble(),
      balanceDue: (json['balanceDue'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String,
      history: json['history'] as List<dynamic>? ?? [],
    );
  }
}

/// Discount Info
class DiscountInfo {
  final List<DiscountBreakdown> discounts;
  final double totalDiscountAmount;

  const DiscountInfo({
    required this.discounts,
    required this.totalDiscountAmount,
  });

  factory DiscountInfo.fromJson(Map<String, dynamic> json) {
    return DiscountInfo(
      discounts: (json['discounts'] as List)
          .map(
            (item) => DiscountBreakdown.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      totalDiscountAmount: (json['totalDiscountAmount'] as num).toDouble(),
    );
  }
}
