import '../repositories/rbac_repository.dart';
import '../entities/role_entity.dart';
import '../entities/permission_entity.dart';
import '../../../authentication/domain/entities/user_entity.dart';

class GetRolesUseCase {
  final RbacRepository repository;
  GetRolesUseCase(this.repository);
  Future<List<RoleEntity>> call() => repository.getRoles();
}

class GetPermissionsUseCase {
  final RbacRepository repository;
  GetPermissionsUseCase(this.repository);
  Future<List<PermissionEntity>> call() => repository.getPermissions();
}

class CreateRoleUseCase {
  final RbacRepository repository;
  CreateRoleUseCase(this.repository);
  Future<RoleEntity> call(
    String name,
    String description,
    List<String> permissionIds,
  ) => repository.createRole(name, description, permissionIds);
}

class UpdateRoleUseCase {
  final RbacRepository repository;
  UpdateRoleUseCase(this.repository);
  Future<RoleEntity> call(
    String id,
    String? name,
    String? description,
    List<String> permissionIds,
  ) => repository.updateRole(id, name, description, permissionIds);
}

class AssignRoleUseCase {
  final RbacRepository repository;
  AssignRoleUseCase(this.repository);
  Future<void> call(String userId, List<String> roleIds) =>
      repository.assignRoles(userId, roleIds);
}

class CreatePermissionUseCase {
  final RbacRepository repository;
  CreatePermissionUseCase(this.repository);
  Future<PermissionEntity> call(
    String name,
    String description,
    String module,
  ) => repository.createPermission(name, description, module);
}

class GetStaffUsersUseCase {
  final RbacRepository repository;
  GetStaffUsersUseCase(this.repository);
  Future<List<UserEntity>> call() => repository.getStaffUsers();
}
