class ApiConstants {
  static const String baseUrl = 'http://localhost:2580/api';

  //version
  static const String v1 = '/v1/';
  static const String v2 = '/v2/';

  //uses

  static const String user = '/user';
  static const String loginEndpoint = '/login';
  static const String menuEndpoint = '/menu';
  static const String menuCurrentEndpoint = '/current';

  //orders
  static const String orders = 'orders';
  static const String myOrders = '/my-orders';
  static const String dineIn = '/dine-in';
  static const String tables = '/tables';

  //discount
  static const String discount = 'discount';

  // Full URLs
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get menuCurrentUrl => '$baseUrl$menuCurrentEndpoint';
  static String get ordersUrl => '$baseUrl$v1$orders';
}
