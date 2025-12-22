/// Menu Entity
/// TODO: When build_runner is fixed, restore Freezed code generation
class MenuEntity {
  final String id;
  final String name;
  final String description;
  final List<CategoryEntity> categories;
  final List<MenuItemEntity> items;

  const MenuEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
    required this.items,
  });

  MenuEntity copyWith({
    String? id,
    String? name,
    String? description,
    List<CategoryEntity>? categories,
    List<MenuItemEntity>? items,
  }) {
    return MenuEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      items: items ?? this.items,
    );
  }

  @override
  String toString() =>
      'MenuEntity(id: $id, name: $name, description: $description)';
}

/// Category Entity
class CategoryEntity {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final int displayOrder;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.displayOrder,
  });

  CategoryEntity copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
    int? displayOrder,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  String toString() => 'CategoryEntity(id: $id, name: $name)';
}

/// Menu Item Entity
class MenuItemEntity {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final bool isAvailable;
  final int preparationTime;
  final List<String> allergens;
  final List<CustomizationOptionEntity> customizationOptions;
  final int popularityScore;
  final double averageRating;
  final CategoryEntity category;
  final bool taxable;
  final TaxRateEntity? taxRate; // Changed from List<dynamic> to TaxRateEntity?
  final int minOrderQuantity;
  final int maxOrderQuantity;
  final List<dynamic> metaData; // Could be more specific based on your needs

  const MenuItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.isAvailable,
    required this.preparationTime,
    required this.allergens,
    required this.customizationOptions,
    required this.popularityScore,
    required this.averageRating,
    required this.category,
    required this.taxable,
    required this.taxRate,
    required this.minOrderQuantity,
    required this.maxOrderQuantity,
    required this.metaData,
  });

  MenuItemEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? image,
    bool? isAvailable,
    int? preparationTime,
    List<String>? allergens,
    List<CustomizationOptionEntity>? customizationOptions,
    int? popularityScore,
    double? averageRating,
    CategoryEntity? category,
    bool? taxable,
    TaxRateEntity? taxRate,
    int? minOrderQuantity,
    int? maxOrderQuantity,
    List<dynamic>? metaData,
  }) {
    return MenuItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      isAvailable: isAvailable ?? this.isAvailable,
      preparationTime: preparationTime ?? this.preparationTime,
      allergens: allergens ?? this.allergens,
      customizationOptions: customizationOptions ?? this.customizationOptions,
      popularityScore: popularityScore ?? this.popularityScore,
      averageRating: averageRating ?? this.averageRating,
      category: category ?? this.category,
      taxable: taxable ?? this.taxable,
      taxRate: taxRate ?? this.taxRate,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      maxOrderQuantity: maxOrderQuantity ?? this.maxOrderQuantity,
      metaData: metaData ?? this.metaData,
    );
  }

  /// Calculate final price including customization options
  double get finalPrice {
    final customizationTotal = customizationOptions
        .where((option) => option.isActive)
        .fold<double>(0, (sum, option) => sum + option.price);
    return price + customizationTotal;
  }

  /// Calculate tax amount based on final price and tax rate
  double get taxAmount {
    if (!taxable || taxRate == null) return 0.0;
    return finalPrice * (taxRate!.percentage / 100);
  }

  /// Calculate total price including tax
  double get totalPriceWithTax {
    return finalPrice + taxAmount;
  }

  @override
  String toString() => 'MenuItemEntity(id: $id, name: $name, price: $price)';
}

class TaxRateEntity {
  final String id;
  final String restaurantId;
  final String name;
  final double percentage;
  final bool isActive;
  final List<MetaDataEntity> metaData;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaxRateEntity({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.percentage,
    required this.isActive,
    required this.metaData,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaxRateEntity.fromJson(Map<String, dynamic> json) {
    return TaxRateEntity(
      id: json['_id'] as String,
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      percentage: (json['percentage'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      metaData: (json['metaData'] as List)
          .map((item) => MetaDataEntity.fromJson(item))
          .toList(),
      version: json['__v'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class MetaDataEntity {
  final String id;
  final String key;
  final dynamic value;

  const MetaDataEntity({
    required this.id,
    required this.key,
    required this.value,
  });

  factory MetaDataEntity.fromJson(Map<String, dynamic> json) {
    return MetaDataEntity(
      id: json['_id'] as String,
      key: json['key'] as String,
      value: json['value'],
    );
  }
}

/// Customization Option Entity
class CustomizationOptionEntity {
  final String id;
  final String name;
  final double price;
  final bool isActive;

  const CustomizationOptionEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.isActive,
  });

  CustomizationOptionEntity copyWith({
    String? id,
    String? name,
    double? price,
    bool? isActive,
  }) {
    return CustomizationOptionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() =>
      'CustomizationOptionEntity(id: $id, name: $name, price: $price)';
}
