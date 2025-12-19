class ApiConstants {
  static const String baseUrl = 'http://localhost:2580';
  static const String loginEndpoint = '/login';

  // Full URLs
  static String get loginUrl => '$baseUrl$loginEndpoint';
}
