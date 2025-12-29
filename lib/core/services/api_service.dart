import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

/// API Service using Dio for all HTTP requests
///
/// This service handles all API calls with:
/// - Automatic token management
/// - Request/Response interceptors
/// - Error handling
/// - Logging in debug mode
class ApiService {
  late final Dio _dio;
  String? _authToken;
  String? _restaurantId;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Accept all status codes to handle them manually
          return status != null && status < 500;
        },
      ),
    );

    _setupInterceptors();
  }

  /// Setup request/response interceptors
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token to headers if available
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
            options.headers['X-Restaurant-Id'] = '$_restaurantId';
          }

          // Log request in debug mode
          if (kDebugMode) {
            print('🌐 REQUEST[${options.method}] => ${options.uri}');
            print('Headers: ${options.headers}');
            if (options.data != null) {
              print('Body: ${options.data}');
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response in debug mode
          if (kDebugMode) {
            print(
              '✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
            );
            print('Data: ${response.data}');
          }

          return handler.next(response);
        },
        onError: (error, handler) {
          // Log error in debug mode
          if (kDebugMode) {
            print(
              '❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}',
            );
            print('Message: ${error.message}');
            if (error.response?.data != null) {
              print('Error Data: ${error.response?.data}');
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

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

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Handle successful response
  ApiResponse<T> _handleResponse<T>(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return ApiResponse.success(
        data: response.data,
        statusCode: response.statusCode!,
      );
    } else {
      // Handle error responses
      final errorMessage = _extractErrorMessage(response.data);
      return ApiResponse.error(errorMessage, statusCode: response.statusCode);
    }
  }

  /// Handle Dio errors
  ApiResponse<T> _handleError<T>(DioException error) {
    String errorMessage;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage =
            'Connection timeout. Please check your internet connection.';
        break;

      case DioExceptionType.badResponse:
        errorMessage =
            _extractErrorMessage(error.response?.data) ??
            'Server error: ${error.response?.statusCode}';
        break;

      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;

      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection. Please check your network.';
        break;

      case DioExceptionType.badCertificate:
        errorMessage = 'Security certificate error';
        break;

      case DioExceptionType.unknown:
      default:
        errorMessage = 'Network error: ${error.message}';
        break;
    }

    return ApiResponse.error(
      errorMessage,
      statusCode: error.response?.statusCode,
    );
  }

  /// Extract error message from response data
  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Unknown error occurred';

    if (data is Map<String, dynamic>) {
      // Try common error message fields
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
      if (data.containsKey('error')) {
        return data['error'].toString();
      }
      if (data.containsKey('msg')) {
        return data['msg'].toString();
      }
    }

    return data.toString();
  }

  /// Get Dio instance for advanced usage
  Dio get dio => _dio;
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
