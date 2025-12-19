class ApiConstants {
  static const String baseUrl = 'http://localhost:2580/api';

  //version
  static const String v1 = '/v1/';

  //uses

  static const String user = '/user';
  static const String loginEndpoint = '/login';

  // Full URLs
  static String get loginUrl => '$baseUrl$loginEndpoint';
}
