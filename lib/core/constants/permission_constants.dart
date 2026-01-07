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
  static const String reportView = "REPORT.VIEW";
  static const String reportExport = "REPORT.EXPORT";

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
    reportView,
    reportExport,
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
