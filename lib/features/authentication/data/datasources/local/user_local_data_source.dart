import 'package:hive/hive.dart';
import '../../../domain/entities/user_entity.dart';

/// Local data source for user using Hive
/// TODO: When build_runner is fixed, restore Drift database
abstract class UserLocalDataSource {
  Future<UserEntity?> getUser();
  Future<void> saveUser(UserEntity user);
  Future<void> deleteUser();
  Future<String?> getToken();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final Box _box;
  static const String _userKey = 'current_user';

  UserLocalDataSourceImpl(this._box);

  @override
  Future<UserEntity?> getUser() async {
    final userData = _box.get(_userKey) as Map<dynamic, dynamic>?;
    if (userData == null) return null;

    return UserEntity(
      id: userData['id'] as String,
      name: userData['name'] as String,
      email: userData['email'] as String,
      token: userData['token'] as String,
      role: userData['role'] as String? ?? 'customer',
      restaurantsId: userData['restaurantsId'] as String?,
      gender: userData['gender'] as String?,
      age: userData['age'] as int?,
    );
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    await _box.put(_userKey, {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'token': user.token,
      'role': user.role,
      'restaurantsId': user.restaurantsId,
      'gender': user.gender,
      'age': user.age,
    });
  }

  @override
  Future<void> deleteUser() async {
    await _box.delete(_userKey);
  }

  @override
  Future<String?> getToken() async {
    final user = await getUser();
    return user?.token;
  }
}
