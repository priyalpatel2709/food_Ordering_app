import 'package:hive/hive.dart';
import '../../../../../core/models/user.dart';
import '../../../../../core/models/role.dart';
import '../../../../../core/models/permission.dart';
import '../../../../rbac/domain/entities/role_entity.dart';
import '../../../../rbac/domain/entities/permission_entity.dart';
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
    // 🔒 READ HIVE OBJECT DIRECTLY
    final userData = _box.get(_userKey);

    if (userData == null) return null;

    if (userData is User) {
      // Map Hive User -> UserEntity
      return UserEntity(
        id: userData.id,
        name: userData.name,
        email: userData.email,
        token: userData.token,
        role: userData.role,
        restaurantsId: userData.restaurantsId,
        gender: userData.gender,
        age: userData.age,
        // Map Roles
        roles: userData.roles?.map((r) => _mapRoleToEntity(r)).toList() ?? [],
      );
    } else if (userData is Map) {
      // Legacy fallback - maybe clear it?
      await _box.delete(_userKey);
      return null;
    }
    return null;
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    // Map UserEntity -> Hive User
    final hiveUser = User(
      id: user.id,
      name: user.name,
      email: user.email,
      token: user.token,
      role: user.role, // roleName
      restaurantsId: user.restaurantsId, // restaurantId
      gender: user.gender,
      age: user.age,
      roles: user.roles.map((r) => _mapEntityToRole(r)).toList(),
      isActive: true, // defaulting
      deviceToken: '', // defaulting
    );
    await _box.put(_userKey, hiveUser);
  }

  // Helpers
  RoleEntity _mapRoleToEntity(Role role) {
    return RoleEntity(
      id: role.id ?? '',
      name: role.name,
      description: role.description,
      isSystem: false, // Hive model might need isSystem, default false
      createdAt: DateTime.now(), // Hive model might need createdAt
      permissions: role.permissions
          .map((p) => _mapPermissionToEntity(p))
          .toList(),
    );
  }

  Role _mapEntityToRole(RoleEntity role) {
    return Role(
      id: role.id,
      name: role.name,
      description: role.description,
      permissions: role.permissions
          .map((p) => _mapEntityToPermission(p))
          .toList(),
      restaurantId: null, // or pass if available
    );
  }

  PermissionEntity _mapPermissionToEntity(Permission p) {
    return PermissionEntity(
      id: p.id,
      name: p.name,
      description: p.description,
      module: p.module,
    );
  }

  Permission _mapEntityToPermission(PermissionEntity p) {
    return Permission(
      id: p.id,
      name: p.name,
      description: p.description,
      module: p.module,
    );
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
