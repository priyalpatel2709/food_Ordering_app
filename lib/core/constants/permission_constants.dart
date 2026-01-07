class PermissionConstants {
  // User Management
  static const String userCreate = "USER.CREATE";
  static const String userRead = "USER.READ";
  static const String userUpdate = "USER.UPDATE";
  static const String userDelete = "USER.DELETE";

  // Role Management (RBAC)
  static const String roleCreate = "ROLE.CREATE";
  static const String roleRead = "ROLE.READ";
  static const String roleUpdate = "ROLE.UPDATE";
  static const String roleDelete = "ROLE.DELETE";
  static const String roleAssign = "ROLE.ASSIGN";

  // Restaurant/Tenant Management
  static const String restaurantCreate = "RESTAURANT.CREATE";
  static const String restaurantUpdate = "RESTAURANT.UPDATE";
  static const String restaurantRead = "RESTAURANT.UPDATE";

  // Menu Management
  static const String menuCreate = "MENU.CREATE";
  static const String menuRead = "MENU.READ";
  static const String menuUpdate = "MENU.UPDATE";
  static const String menuDelete = "MENU.DELETE";

  // Order Management
  static const String orderCreate = "ORDER.CREATE";
  static const String orderRead = "ORDER.READ";
  static const String orderUpdate = "ORDER.UPDATE";
  static const String orderDelete = "ORDER.DELETE";

  // KDS
  static const String kdsView = "KDS.VIEW";
  static const String kdsManage = "KDS.MANAGE";

  // Reports
  static const String reportRead = "REPORT.VIEW";
  static const String reportExport = "REPORT.EXPORT";

  //item
  static const String itemCreate = "ITEM.CREATE";
  static const String itemRead = "ITEM.READ";
  static const String itemUpdate = "ITEM.UPDATE";
  static const String itemDelete = "ITEM.DELETE";

  //category
  static const String categoryCreate = "CATEGORY.CREATE";
  static const String categoryRead = "CATEGORY.READ";
  static const String categoryUpdate = "CATEGORY.UPDATE";
  static const String categoryDelete = "CATEGORY.DELETE";

  //customization
  static const String customizationCreate = "CUSTOMIZATION.CREATE";
  static const String customizationRead = "CUSTOMIZATION.READ";
  static const String customizationUpdate = "CUSTOMIZATION.UPDATE";
  static const String customizationDelete = "CUSTOMIZATION.DELETE";

  //discount
  static const String discountCreate = "DISCOUNT.CREATE";
  static const String discountRead = "DISCOUNT.READ";
  static const String discountUpdate = "DISCOUNT.UPDATE";
  static const String discountDelete = "DISCOUNT.DELETE";

  //Tax
  static const String taxCreate = "TAX.CREATE";
  static const String taxRead = "TAX.READ";
  static const String taxUpdate = "TAX.UPDATE";
  static const String taxDelete = "TAX.DELETE";

  static const List<String> values = [
    userCreate,
    userRead,
    userUpdate,
    userDelete,
    roleCreate,
    roleRead,
    roleUpdate,
    roleDelete,
    roleAssign,
    restaurantCreate,
    restaurantUpdate,
    menuCreate,
    menuRead,
    menuUpdate,
    menuDelete,
    orderCreate,
    orderRead,
    orderUpdate,
    orderDelete,
    kdsView,
    kdsManage,
    reportRead,
    reportExport,
    itemCreate,
    itemRead,
    itemUpdate,
    itemDelete,
    categoryCreate,
    categoryRead,
    categoryUpdate,
    categoryDelete,
    customizationCreate,
    customizationRead,
    customizationUpdate,
    customizationDelete,
    discountCreate,
    discountRead,
    discountUpdate,
    discountDelete,
    taxCreate,
    taxRead,
    taxUpdate,
    taxDelete,
  ];

  static const Map<String, String> modules = {
    'USER': "USER",
    'ROLE': "ROLE",
    'RESTAURANT': "RESTAURANT",
    'MENU': "MENU",
    'ORDER': "ORDER",
    'KDS': "KDS",
    'REPORT': "REPORT",
  };
}
