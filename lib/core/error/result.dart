import 'failures.dart';

/// Result type for handling success/failure states
/// TODO: When build_runner is fixed, restore Freezed code generation
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = ResultFailure<T>;

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is ResultFailure<T>;

  /// Get data or null
  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    ResultFailure() => null,
  };

  /// Get failure or null
  Failure? get failureOrNull => switch (this) {
    Success() => null,
    ResultFailure(:final failure) => failure,
  };

  /// Pattern matching helper
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else {
      return failure((this as ResultFailure<T>).failure);
    }
  }
}

/// Success result
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Failure result
final class ResultFailure<T> extends Result<T> {
  final Failure failure;

  const ResultFailure(this.failure);

  @override
  String toString() => 'ResultFailure(failure: $failure)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultFailure<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}
