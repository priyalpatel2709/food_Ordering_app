import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/dio_client.dart';
import '../../dto/user_dto.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  Future<UserDto> login(String email, String password);
  Future<UserDto> signUp({
    required String name,
    required String email,
    required String password,
    required String restaurantId,
    String? gender,
    int? age,
  });
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserDto> login(String email, String password) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.user}${ApiConstants.loginEndpoint}',
      data: {'email': email, 'password': password},
    );

    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserDto> signUp({
    required String name,
    required String email,
    required String password,
    required String restaurantId,
    String? gender,
    int? age,
  }) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.user}',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'restaurantId': restaurantId,
        if (gender != null) 'gender': gender,
        if (age != null) 'age': age,
      },
    );

    return UserDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _dioClient.post('/logout');
  }
}
