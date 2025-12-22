/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Server exception (API errors)
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// Network exception (connectivity issues)
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Cache exception (local storage errors)
class CacheException extends AppException {
  const CacheException(super.message);
}

/// Validation exception (input validation errors)
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Unauthorized exception (auth errors)
class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.statusCode});
}

/// Not found exception
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.statusCode});
}
