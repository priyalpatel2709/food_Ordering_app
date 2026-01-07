import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/user_local_data_source.dart';
import '../datasources/remote/auth_remote_data_source.dart';

/// Auth Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;
  final DioClient _dioClient;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._dioClient,
  );

  @override
  Future<Result<UserEntity>> login(String email, String password) async {
    try {
      final userDto = await _remoteDataSource.login(email, password);
      final userEntity = userDto.toEntity();

      // Save user locally
      await _localDataSource.saveUser(userEntity);

      // Set token in DioClient
      _dioClient.setAuthToken(userEntity.token);

      // Reload from local storage to ensure consistency
      final savedUser = await _localDataSource.getUser();
      return Result.success(savedUser ?? userEntity);
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on UnauthorizedException catch (e) {
      return Result.failure(Failure.unauthorized(e.message));
    } on CacheException catch (e) {
      return Result.failure(Failure.cache(e.message));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signUp({
    required String name,
    required String email,
    required String password,
    required String restaurantId,
    required String roleName,
    String? gender,
    int? age,
  }) async {
    try {
      final userDto = await _remoteDataSource.signUp(
        name: name,
        email: email,
        password: password,
        restaurantId: restaurantId,
        gender: gender,
        age: age,
        roleName: roleName,
      );
      final userEntity = userDto.toEntity();

      // Save user locally
      await _localDataSource.saveUser(userEntity);

      // Set token in DioClient
      _dioClient.setAuthToken(userEntity.token);

      // Reload to ensure consistency
      final savedUser = await _localDataSource.getUser();
      return Result.success(savedUser ?? userEntity);
    } on ServerException catch (e) {
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } on NetworkException catch (e) {
      return Result.failure(Failure.network(e.message));
    } on CacheException catch (e) {
      return Result.failure(Failure.cache(e.message));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.deleteUser();
      _dioClient.clearAuthToken();
      return const Result.success(null);
    } on ServerException catch (e) {
      // Still clear local data even if remote logout fails
      await _localDataSource.deleteUser();
      _dioClient.clearAuthToken();
      return Result.failure(
        Failure.server(e.message, statusCode: e.statusCode),
      );
    } on NetworkException catch (e) {
      // Still clear local data even if network fails
      await _localDataSource.deleteUser();
      _dioClient.clearAuthToken();
      return Result.failure(Failure.network(e.message));
    } catch (e) {
      await _localDataSource.deleteUser();
      _dioClient.clearAuthToken();
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final user = await _localDataSource.getUser();
      return Result.success(user);
    } on CacheException catch (e) {
      return Result.failure(Failure.cache(e.message));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<String?>> getToken() async {
    try {
      final token = await _localDataSource.getToken();
      return Result.success(token);
    } on CacheException catch (e) {
      return Result.failure(Failure.cache(e.message));
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }
}
