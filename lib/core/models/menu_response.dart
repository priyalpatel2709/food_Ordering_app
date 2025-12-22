class MenuResponse {
  final bool success;
  final String currentDay;
  final String currentTime;
  final List<Menu> menus;

  MenuResponse({
    required this.success,
    required this.currentDay,
    required this.currentTime,
    required this.menus,
  });

  factory MenuResponse.fromJson(Map<String, dynamic> json) {
    return MenuResponse(
      success: json['success'] as bool,
      currentDay: json['currentDay'] as String,
      currentTime: json['currentTime'] as String,
      menus: (json['menus'] as List)
          .map((e) => Menu.fromJson(e as Map<String, dynamic>))
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

class Menu {
  final String id;
  final String name;
  final String description;
  final List<Category> categories;
  final List<MenuItem> items;

  Menu({
    required this.id,
    required this.name,
    required this.description,
    required this.categories,
    required this.items,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      categories: (json['categories'] as List)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List)
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
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
}

class Category {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final bool isActive;
  final int displayOrder;
  final List<dynamic> metaData;
  final int? v;
  final String? createdAt;
  final String? updatedAt;

  Category({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.isActive,
    required this.displayOrder,
    required this.metaData,
    this.v,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] as String,
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      isActive: json['isActive'] as bool,
      displayOrder: json['displayOrder'] as int,
      metaData: json['metaData'] as List<dynamic>,
      v: json['__v'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
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
      'metaData': metaData,
      '__v': v,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class MenuItem {
  final Item item;
  final double defaultPrice;
  final String id;

  MenuItem({required this.item, required this.defaultPrice, required this.id});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      item: Item.fromJson(json['item'] as Map<String, dynamic>),
      defaultPrice: (json['defaultPrice'] as num).toDouble(),
      id: json['_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'item': item.toJson(), 'defaultPrice': defaultPrice, '_id': id};
  }
}

class Item {
  final String id;
  final String restaurantId;
  final Category category;
  final String name;
  final String description;
  final double price;
  final String image;
  final bool isAvailable;
  final int preparationTime;
  final List<String> allergens;
  final List<CustomizationOption> customizationOptions;
  final int popularityScore;
  final double averageRating;
  final bool taxable;
  final List<dynamic> taxRate;
  final int minOrderQuantity;
  final int maxOrderQuantity;
  final List<dynamic> metaData;
  final int? v;
  final String? createdAt;
  final String? updatedAt;
  final double finalPrice;

  Item({
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
    this.v,
    this.createdAt,
    this.updatedAt,
    required this.finalPrice,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'] as String,
      restaurantId: json['restaurantId'] as String,
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      isAvailable: json['isAvailable'] as bool,
      preparationTime: json['preparationTime'] as int,
      allergens: (json['allergens'] as List).cast<String>(),
      customizationOptions: (json['customizationOptions'] as List)
          .map((e) => CustomizationOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      popularityScore: json['popularityScore'] as int,
      averageRating: (json['averageRating'] as num).toDouble(),
      taxable: json['taxable'] as bool,
      taxRate: json['taxRate'] as List<dynamic>,
      minOrderQuantity: json['minOrderQuantity'] as int,
      maxOrderQuantity: json['maxOrderQuantity'] as int,
      metaData: json['metaData'] as List<dynamic>,
      v: json['__v'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      finalPrice: (json['finalPrice'] as num).toDouble(),
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
      'taxRate': taxRate,
      'minOrderQuantity': minOrderQuantity,
      'maxOrderQuantity': maxOrderQuantity,
      'metaData': metaData,
      '__v': v,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'finalPrice': finalPrice,
    };
  }
}

class CustomizationOption {
  final String id;
  final String restaurantId;
  final String name;
  final double price;
  final bool isActive;
  final List<dynamic> metaData;
  final int? v;
  final String? createdAt;
  final String? updatedAt;

  CustomizationOption({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    required this.isActive,
    required this.metaData,
    this.v,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) {
    return CustomizationOption(
      id: json['_id'] as String,
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      metaData: json['metaData'] as List<dynamic>,
      v: json['__v'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantId': restaurantId,
      'name': name,
      'price': price,
      'isActive': isActive,
      'metaData': metaData,
      '__v': v,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
