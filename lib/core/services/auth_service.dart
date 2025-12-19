import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/user.dart';

class AuthService {
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        return AuthResult.success(user);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Login failed';
        return AuthResult.error(errorMessage);
      }
    } catch (e) {
      return AuthResult.error('Network error: ${e.toString()}');
    }
  }
}

class AuthResult {
  final User? user;
  final String? error;
  final bool isSuccess;

  AuthResult._({this.user, this.error, required this.isSuccess});

  factory AuthResult.success(User user) {
    return AuthResult._(user: user, isSuccess: true);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(error: error, isSuccess: false);
  }
}
