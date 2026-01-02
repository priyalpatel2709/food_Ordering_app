import '../../domain/entities/menu_entity.dart';
import '../../../../core/domain/entities/paginated_data.dart';

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
      success: (json['success'] as bool?) ?? true,
      currentDay: (json['currentDay'] as String?) ?? '',
      currentTime: (json['currentTime'] as String?) ?? '',
      menus: json['menus'] is List
          ? (json['menus'] as List<dynamic>)
                .map((e) => MenuDto.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
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
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      categories: json['categories'] is List
          ? (json['categories'] as List<dynamic>)
                .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      items: json['items'] is List
          ? (json['items'] as List<dynamic>)
                .map(
                  (e) => MenuItemWrapperDto.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
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
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      restaurantId: (json['restaurantId'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      isActive: (json['isActive'] as bool?) ?? true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
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
      item: MenuItemDto.fromJson((json['item'] as Map<String, dynamic>?) ?? {}),
      defaultPrice: (json['defaultPrice'] as num?)?.toDouble() ?? 0.0,
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
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
  final bool taxable;
  final TaxRateDto? taxRate;
  final int minOrderQuantity;
  final int maxOrderQuantity;
  final List<dynamic> metaData;

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
    required this.taxable,
    required this.taxRate,
    required this.minOrderQuantity,
    required this.maxOrderQuantity,
    required this.metaData,
  });

  factory MenuItemDto.fromJson(Map<String, dynamic> json) {
    return MenuItemDto(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      restaurantId: json['restaurantId'] as String? ?? '',
      category: CategoryDto.fromJson(
        (json['category'] as Map<String, dynamic>?) ?? {},
      ),
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: (json['image'] as String?) ?? '',
      isAvailable: (json['isAvailable'] as bool?) ?? true,
      preparationTime: (json['preparationTime'] as num?)?.toInt() ?? 0,
      allergens: json['allergens'] is List
          ? (json['allergens'] as List<dynamic>).cast<String>()
          : [],
      customizationOptions: json['customizationOptions'] is List
          ? (json['customizationOptions'] as List<dynamic>)
                .map(
                  (e) => CustomizationOptionDto.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : [],
      popularityScore: (json['popularityScore'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      taxable: (json['taxable'] as bool?) ?? false,
      taxRate: json['taxRate'] != null && json['taxRate'] is Map
          ? TaxRateDto.fromJson(json['taxRate'] as Map<String, dynamic>)
          : null,
      minOrderQuantity: (json['minOrderQuantity'] as num?)?.toInt() ?? 1,
      maxOrderQuantity: (json['maxOrderQuantity'] as num?)?.toInt() ?? 99,
      metaData: (json['metaData'] as List<dynamic>?) ?? [],
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
      'taxable': taxable,
      'taxRate': taxRate?.toJson(),
      'minOrderQuantity': minOrderQuantity,
      'maxOrderQuantity': maxOrderQuantity,
      'metaData': metaData,
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
      taxable: taxable,
      taxRate: taxRate?.toEntity(),
      minOrderQuantity: minOrderQuantity,
      maxOrderQuantity: maxOrderQuantity,
      metaData: metaData,
    );
  }
}

class TaxRateDto {
  final String id;
  final String restaurantId;
  final String name;
  final double percentage;
  final bool isActive;
  final List<MetaDataDto> metaData;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaxRateDto({
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

  factory TaxRateDto.fromJson(Map<String, dynamic> json) {
    return TaxRateDto(
      id: json['_id'] as String? ?? '',
      restaurantId: (json['restaurantId'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      isActive: (json['isActive'] as bool?) ?? true,
      metaData: json['metaData'] is List
          ? (json['metaData'] as List<dynamic>)
                .map(
                  (item) => MetaDataDto.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : [],
      version: (json['__v'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantId': restaurantId,
      'name': name,
      'percentage': percentage,
      'isActive': isActive,
      'metaData': metaData.map((e) => e.toJson()).toList(),
      '__v': version,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TaxRateEntity toEntity() {
    return TaxRateEntity(
      id: id,
      restaurantId: restaurantId,
      name: name,
      percentage: percentage,
      isActive: isActive,
      metaData: metaData.map((e) => e.toEntity()).toList(),
      version: version,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class MetaDataDto {
  final String id;
  final String key;
  final dynamic value;

  const MetaDataDto({required this.id, required this.key, required this.value});

  factory MetaDataDto.fromJson(Map<String, dynamic> json) {
    return MetaDataDto(
      id: (json['_id'] as String?) ?? '',
      key: (json['key'] as String?) ?? '',
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'key': key, 'value': value};
  }

  MetaDataEntity toEntity() {
    return MetaDataEntity(id: id, key: key, value: value);
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
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      restaurantId: (json['restaurantId'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isActive: (json['isActive'] as bool?) ?? true,
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

class PaginatedResponseDto<T> {
  final int page;
  final int limit;
  final int totalDocs;
  final int totalPages;
  final List<T> data;

  PaginatedResponseDto({
    required this.page,
    required this.limit,
    required this.totalDocs,
    required this.totalPages,
    required this.data,
  });

  factory PaginatedResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponseDto(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalDocs: json['totalDocs'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  PaginatedData<E> toPaginatedData<E>(E Function(T) toEntity) {
    return PaginatedData<E>(
      items: data.map(toEntity).toList(),
      page: page,
      limit: limit,
      totalDocs: totalDocs,
      totalPages: totalPages,
    );
  }
}
