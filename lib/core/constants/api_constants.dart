import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:2580/api'
      : 'http://localhost:2580/api';

  //version
  static const String v1 = '/v1/';
  static const String v2 = '/v2/';

  //uses

  // auth
  static const String user = 'user';
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';

  // menu & crud
  static const String menuEndpoint = 'menu';
  static const String menuCurrentEndpoint = '/current';
  static const String menuCreateEndpoint = '/createMenu';
  static const String menuUpdateAdvanced = '/updateById';
  static const String menuAddItemEndpoint = '/add-item';

  static const String itemEndpoint = 'item';
  static const String categoryEndpoint = 'category';
  static const String customizationOptionEndpoint = 'customizationOption';
  static const String taxEndpoint = 'tax';
  static const String orderTypeEndpoint = 'orderType';
  static const String restaurantEndpoint = 'restaurant';

  // orders
  static const String orders = 'orders';
  static const String myOrders = '/my-orders';
  static const String dineIn = '/dine-in';
  static const String tables = '/tables';

  // discount
  static const String discount = 'discount';

  // kds
  static const String kds = 'kds';
  static const String kdsConfig = '/config';

  // dashboard
  static const String dashboard = 'dashboard';
  static const String dashboardStats = '/stats';
  static const String dashboardExport = '/export';

  //payment
  static const String payment = 'payment';
  static const String refund = '/refund';

  // Full URLs
  static String get loginUrl => '$baseUrl$v1$user$loginEndpoint';
  static String get registerUrl => '$baseUrl$v1$user$registerEndpoint';
  static String get menuCurrentUrl =>
      '$baseUrl$v1$menuEndpoint$menuCurrentEndpoint';
  static String get ordersUrl => '$baseUrl$v1$orders';
}
