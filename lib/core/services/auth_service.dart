import '../constants/api_constants.dart';
import '../models/user.dart';
import 'api_service.dart';

/// Authentication Service
///
/// Handles all authentication-related operations using ApiService
class AuthService {
  final ApiService _apiService = ApiService();

  /// Login with email and password
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.v1}${ApiConstants.user}${ApiConstants.loginEndpoint}',
        data: {'email': email, 'password': password},
      );

      if (response.isSuccess && response.data != null) {
        final user = User.fromJson(response.data as Map<String, dynamic>);

        // Set auth token in API service for future requests
        _apiService.setAuthToken(user.token);

        return AuthResult.success(user);
      } else {
        return AuthResult.error(response.error ?? 'Login failed');
      }
    } catch (e) {
      return AuthResult.error('An error occurred: ${e.toString()}');
    }
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.v1}${ApiConstants.user}',
        data: {
          'email': email,
          'password': password,
          'name': name,
          "restaurantId": "restaurant_123",
        },
      );

      if (response.isSuccess && response.data != null) {
        final user = User.fromJson(response.data as Map<String, dynamic>);

        // Set auth token in API service for future requests
        _apiService.setAuthToken(user.token);

        return AuthResult.success(user);
      } else {
        return AuthResult.error(response.error ?? 'Login failed');
      }
    } catch (e) {
      return AuthResult.error('An error occurred: ${e.toString()}');
    }
  }

  /// Register new user
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.isSuccess && response.data != null) {
        final user = User.fromJson(response.data as Map<String, dynamic>);
        _apiService.setAuthToken(user.token);
        return AuthResult.success(user);
      } else {
        return AuthResult.error(response.error ?? 'Registration failed');
      }
    } catch (e) {
      return AuthResult.error('An error occurred: ${e.toString()}');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _apiService.post('/logout');
    } catch (e) {
      // Ignore logout errors
    } finally {
      // Clear token from API service
      _apiService.clearAuthToken();
    }
  }

  /// Verify token
  Future<bool> verifyToken(String token) async {
    try {
      _apiService.setAuthToken(token);
      final response = await _apiService.get('/verify-token');
      return response.isSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Forgot password
  Future<AuthResult> forgotPassword(String email) async {
    try {
      final response = await _apiService.post(
        '/forgot-password',
        data: {'email': email},
      );

      if (response.isSuccess) {
        return AuthResult.success(null);
      } else {
        return AuthResult.error(response.error ?? 'Failed to send reset email');
      }
    } catch (e) {
      return AuthResult.error('An error occurred: ${e.toString()}');
    }
  }

  /// Reset password
  Future<AuthResult> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        '/reset-password',
        data: {'token': token, 'password': newPassword},
      );

      if (response.isSuccess) {
        return AuthResult.success(null);
      } else {
        return AuthResult.error(response.error ?? 'Failed to reset password');
      }
    } catch (e) {
      return AuthResult.error('An error occurred: ${e.toString()}');
    }
  }

  /// Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        '/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      if (response.isSuccess) {
        return AuthResult.success(null);
      } else {
        return AuthResult.error(response.error ?? 'Failed to change password');
      }
    } catch (e) {
      return AuthResult.error('An error occurred: ${e.toString()}');
    }
  }

  /// Get current user profile
  Future<AuthResult> getCurrentUser() async {
    try {
      final response = await _apiService.get('/profile');

      if (response.isSuccess && response.data != null) {
        final user = User.fromJson(response.data as Map<String, dynamic>);
        return AuthResult.success(user);
      } else {
        return AuthResult.error(response.error ?? 'Failed to get user profile');
      }
    } catch (e) {
      return AuthResult.error('An error occurred: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<AuthResult> updateProfile({String? name, String? email}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;

      final response = await _apiService.put('/profile', data: data);

      if (response.isSuccess && response.data != null) {
        final user = User.fromJson(response.data as Map<String, dynamic>);
        return AuthResult.success(user);
      } else {
        return AuthResult.error(response.error ?? 'Failed to update profile');
      }
    } catch (e) {
      return AuthResult.error('An error occurred: ${e.toString()}');
    }
  }
}

/// Authentication Result wrapper
class AuthResult {
  final User? user;
  final String? error;
  final bool isSuccess;

  AuthResult._({this.user, this.error, required this.isSuccess});

  factory AuthResult.success(User? user) {
    return AuthResult._(user: user, isSuccess: true);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(error: error, isSuccess: false);
  }

  bool get isError => !isSuccess;
}
