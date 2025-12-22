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
    );
  }

  /// Calculate final price including customization options
  double get finalPrice {
    final customizationTotal = customizationOptions
        .where((option) => option.isActive)
        .fold<double>(0, (sum, option) => sum + option.price);
    return price + customizationTotal;
  }

  @override
  String toString() => 'MenuItemEntity(id: $id, name: $name, price: $price)';
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
