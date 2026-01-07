import '../../../../core/error/result.dart';
import '../entities/user_entity.dart';

/// Auth Repository Interface - Pure domain
abstract class AuthRepository {
  Future<Result<UserEntity>> login(String email, String password);
  Future<Result<UserEntity>> signUp({
    required String name,
    required String email,
    required String password,
    required String restaurantId,
    required String roleName,
    String? gender,
    int? age,
  });
  Future<Result<void>> logout();
  Future<Result<UserEntity?>> getCurrentUser();
  Future<Result<String?>> getToken();
}
