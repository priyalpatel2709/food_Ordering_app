import '../../../authentication/domain/entities/user_entity.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/entities/permission_entity.dart';

abstract class RbacRepository {
  Future<List<RoleEntity>> getRoles();
  Future<List<PermissionEntity>> getPermissions();
  Future<RoleEntity> createRole(
    String name,
    String description,
    List<String> permissionIds,
  );
  Future<void> assignRoles(String userId, List<String> roleIds);
  Future<List<UserEntity>> getStaffUsers();
  Future<RoleEntity> updateRole(
    String id,
    String? name,
    String? description,
    List<String> permissionIds,
  );
  Future<PermissionEntity> createPermission(
    String name,
    String description,
    String module,
  );
}
