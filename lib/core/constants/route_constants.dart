/// Route constants for the application
///
/// This file contains all the route paths and names used in the app.
/// Use these constants instead of hardcoded strings for better maintainability.
class RouteConstants {
  // Private constructor to prevent instantiation
  RouteConstants._();

  // Route Paths
  static const String splash = '/';
  static const String login = '/login';
  static const String signin = '/signin';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String menu = '/menu';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String orderDetails = '/orders/:orderId';
  static const String settings = '/settings';
  static const String favorites = '/favorites';
  static const String search = '/search';
  static const String staffHome = '/staff/home';
  static const String dineInTables = '/dine-in/tables';
  static const String dineInTableDetails = '/dine-in/table/:id';
  static const String kds = '/kds';
  static const String menuManagement = '/staff/menu-management';
  static const String itemsManagement = '/staff/items';
  static const String categoriesManagement = '/staff/categories';
  static const String customizationManagement = '/staff/customizations';
  static const String discountsManagement = '/staff/discounts';
  static const String taxesManagement = '/staff/taxes';
  static const String restaurantSettings = '/staff/restaurant-settings';
  static const String reports = '/staff/reports';
  static const String addItem = '/staff/items/add';
  static const String addMenu = '/staff/menu/add';

  // Route Names (for named navigation)
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String signInName = 'signin';
  static const String homeName = 'home';
  static const String profileName = 'profile';
  static const String menuName = 'menu';
  static const String cartName = 'cart';
  static const String ordersName = 'orders';
  static const String orderDetailsName = 'orderDetails';
  static const String settingsName = 'settings';
  static const String favoritesName = 'favorites';
  static const String searchName = 'search';
  static const String staffHomeName = 'staffHome';
  static const String dineInTablesName = 'dineInTables';
  static const String dineInTableDetailsName = 'dineInTableDetails';
  static const String kdsName = 'kds';
  static const String menuManagementName = 'menuManagement';
  static const String itemsManagementName = 'itemsManagement';
  static const String categoriesManagementName = 'categoriesManagement';
  static const String customizationManagementName = 'customizationManagement';
  static const String discountsManagementName = 'discountsManagement';
  static const String taxesManagementName = 'taxesManagement';
  static const String restaurantSettingsName = 'restaurantSettings';
  static const String reportsName = 'reports';
  static const String addItemName = 'addItem';
}
