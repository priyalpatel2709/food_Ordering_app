/// API Service using Dio for all HTTP requests
///
/// This service handles all API calls with:
/// - Automatic token management
/// - Request/Response interceptors
/// - Error handling
/// - Logging in debug mode
class ApiService {
  String? _authToken;
  String? _restaurantId;

  /// Set authentication token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  void setRestaurantId(String? restaurantId) {
    _restaurantId = restaurantId;
  }

  /// Get authentication token
  String? getAuthToken() => _authToken;
  String? getRestaurantId() => _restaurantId;

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
    _restaurantId = null;
  }
}

/// Generic API Response wrapper
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;
  final int? statusCode;

  ApiResponse._({
    this.data,
    this.error,
    required this.isSuccess,
    this.statusCode,
  });

  factory ApiResponse.success({required T data, required int statusCode}) {
    return ApiResponse._(data: data, isSuccess: true, statusCode: statusCode);
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse._(
      error: error,
      isSuccess: false,
      statusCode: statusCode,
    );
  }

  /// Check if response is successful
  bool get isError => !isSuccess;

  /// Get data or throw error
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data as T;
    }
    throw Exception(error ?? 'No data available');
  }
}
