import '../../domain/entities/menu_entity.dart';

/// Menu Response DTO
class MenuResponseDto {
  final bool success;
  final String currentDay;
  final String currentTime;
  final List<MenuDto> menus;

  const MenuResponseDto({
    required this.success,
    required this.currentDay,
    required this.currentTime,
    required this.menus,
  });

  factory MenuResponseDto.fromJson(Map<String, dynamic> json) {
    return MenuResponseDto(
      success: json['success'] as bool,
      currentDay: json['currentDay'] as String,
      currentTime: json['currentTime'] as String,
      menus: (json['menus'] as List<dynamic>)
          .map((e) => MenuDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'currentDay': currentDay,
      'currentTime': currentTime,
      'menus': menus.map((e) => e.toJson()).toList(),
    };
  }
}

/// Menu DTO
class MenuDto {
  final String id;
  final String name;
  final String description;
  final List<CategoryDto> categories;
  final List<MenuItemWrapperDto> items;

  const MenuDto({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
    required this.items,
  });

  factory MenuDto.fromJson(Map<String, dynamic> json) {
    return MenuDto(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List<dynamic>)
          .map((e) => MenuItemWrapperDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'categories': categories.map((e) => e.toJson()).toList(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  /// Convert to Entity
  MenuEntity toEntity() {
    return MenuEntity(
      id: id,
      name: name,
      description: description,
      categories: categories.map((c) => c.toEntity()).toList(),
      items: items.map((i) => i.item.toEntity()).toList(),
    );
  }
}

/// Category DTO
class CategoryDto {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final bool isActive;
  final int displayOrder;

  const CategoryDto({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.isActive,
    required this.displayOrder,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['_id'] as String? ?? json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      isActive: json['isActive'] as bool,
      displayOrder: json['displayOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantId': restaurantId,
      'name': name,
      'description': description,
      'isActive': isActive,
      'displayOrder': displayOrder,
    };
  }

  /// Convert to Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      isActive: isActive,
      displayOrder: displayOrder,
    );
  }
}

/// Menu Item Wrapper DTO
class MenuItemWrapperDto {
  final MenuItemDto item;
  final double defaultPrice;
  final String id;

  const MenuItemWrapperDto({
    required this.item,
    required this.defaultPrice,
    required this.id,
  });

  factory MenuItemWrapperDto.fromJson(Map<String, dynamic> json) {
    return MenuItemWrapperDto(
      item: MenuItemDto.fromJson(json['item'] as Map<String, dynamic>),
      defaultPrice: (json['defaultPrice'] as num).toDouble(),
      id: json['_id'] as String? ?? json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'item': item.toJson(), 'defaultPrice': defaultPrice, '_id': id};
  }
}

/// Menu Item DTO
class MenuItemDto {
  final String id;
  final String restaurantId;
  final CategoryDto category;
  final String name;
  final String description;
  final double price;
  final String image;
  final bool isAvailable;
  final int preparationTime;
  final List<String> allergens;
  final List<CustomizationOptionDto> customizationOptions;
  final int popularityScore;
  final double averageRating;

  const MenuItemDto({
    required this.id,
    required this.restaurantId,
    required this.category,
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
  });

  factory MenuItemDto.fromJson(Map<String, dynamic> json) {
    return MenuItemDto(
      id: json['_id'] as String? ?? json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      category: CategoryDto.fromJson(json['category'] as Map<String, dynamic>),
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      isAvailable: json['isAvailable'] as bool,
      preparationTime: json['preparationTime'] as int,
      allergens: (json['allergens'] as List<dynamic>).cast<String>(),
      customizationOptions: (json['customizationOptions'] as List<dynamic>)
          .map(
            (e) => CustomizationOptionDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      popularityScore: json['popularityScore'] as int,
      averageRating: (json['averageRating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantId': restaurantId,
      'category': category.toJson(),
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'isAvailable': isAvailable,
      'preparationTime': preparationTime,
      'allergens': allergens,
      'customizationOptions': customizationOptions
          .map((e) => e.toJson())
          .toList(),
      'popularityScore': popularityScore,
      'averageRating': averageRating,
    };
  }

  /// Convert to Entity
  MenuItemEntity toEntity() {
    return MenuItemEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      image: image,
      isAvailable: isAvailable,
      preparationTime: preparationTime,
      allergens: allergens,
      customizationOptions: customizationOptions
          .map((o) => o.toEntity())
          .toList(),
      popularityScore: popularityScore,
      averageRating: averageRating,
      category: category.toEntity(),
    );
  }
}

/// Customization Option DTO
class CustomizationOptionDto {
  final String id;
  final String restaurantId;
  final String name;
  final double price;
  final bool isActive;

  const CustomizationOptionDto({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.isActive,
  });

  factory CustomizationOptionDto.fromJson(Map<String, dynamic> json) {
    return CustomizationOptionDto(
      id: json['_id'] as String? ?? json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantId': restaurantId,
      'name': name,
      'price': price,
      'isActive': isActive,
    };
  }

  /// Convert to Entity
  CustomizationOptionEntity toEntity() {
    return CustomizationOptionEntity(
      id: id,
      name: name,
      price: price,
      isActive: isActive,
    );
  }
}
