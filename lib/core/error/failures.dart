/// Base Failure class for error handling
/// TODO: When build_runner is fixed, restore Freezed code generation
sealed class Failure {
  final String message;

  const Failure(this.message);

  // Factory constructors for different failure types
  const factory Failure.server(String message, {int? statusCode}) =
      ServerFailure;
  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.cache(String message) = CacheFailure;
  const factory Failure.validation(String message) = ValidationFailure;
  const factory Failure.unauthorized(String message) = UnauthorizedFailure;
  const factory Failure.notFound(String message) = NotFoundFailure;
  const factory Failure.unknown(String message) = UnknownFailure;

  // Pattern matching helper
  T when<T>({
    required T Function(String message, int? statusCode) server,
    required T Function(String message) network,
    required T Function(String message) cache,
    required T Function(String message) validation,
    required T Function(String message) unauthorized,
    required T Function(String message) notFound,
    required T Function(String message) unknown,
  }) {
    return switch (this) {
      ServerFailure(:final message, :final statusCode) => server(
        message,
        statusCode,
      ),
      NetworkFailure(:final message) => network(message),
      CacheFailure(:final message) => cache(message),
      ValidationFailure(:final message) => validation(message),
      UnauthorizedFailure(:final message) => unauthorized(message),
      NotFoundFailure(:final message) => notFound(message),
      UnknownFailure(:final message) => unknown(message),
    };
  }
}

/// Server error failure
final class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  String toString() =>
      'ServerFailure(message: $message, statusCode: $statusCode)';
}

/// Network error failure
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);

  @override
  String toString() => 'NetworkFailure(message: $message)';
}

/// Cache error failure
final class CacheFailure extends Failure {
  const CacheFailure(super.message);

  @override
  String toString() => 'CacheFailure(message: $message)';
}

/// Validation error failure
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);

  @override
  String toString() => 'ValidationFailure(message: $message)';
}

/// Unauthorized error failure
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);

  @override
  String toString() => 'UnauthorizedFailure(message: $message)';
}

/// Not found error failure
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);

  @override
  String toString() => 'NotFoundFailure(message: $message)';
}

/// Unknown error failure
final class UnknownFailure extends Failure {
  const UnknownFailure(super.message);

  @override
  String toString() => 'UnknownFailure(message: $message)';
}
