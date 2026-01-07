import '../../domain/repositories/rbac_repository.dart';
import '../../data/datasources/rbac_remote_data_source.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/entities/permission_entity.dart';

class RbacRepositoryImpl implements RbacRepository {
  final RbacRemoteDataSource _remoteDataSource;

  RbacRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<RoleEntity>> getRoles() async {
    final dtos = await _remoteDataSource.getRoles();
    return dtos.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<PermissionEntity>> getPermissions() async {
    final dtos = await _remoteDataSource.getPermissions();
    return dtos.map((e) => e.toEntity()).toList();
  }

  @override
  Future<RoleEntity> createRole(
    String name,
    String description,
    List<String> permissionIds,
    String restaurantId,
  ) async {
    final dto = await _remoteDataSource.createRole(
      name,
      description,
      permissionIds,
      restaurantId,
    );
    return dto.toEntity();
  }

  @override
  Future<void> assignRoles(String userId, List<String> roleIds) async {
    await _remoteDataSource.assignRoles(userId, roleIds);
  }

  @override
  Future<List<UserEntity>> getStaffUsers() async {
    final dtos = await _remoteDataSource.getStaffUsers();
    return dtos.map((e) => e.toEntity()).toList();
  }

  @override
  Future<RoleEntity> updateRole(
    String id,
    String? name,
    String? description,
    List<String> permissionIds,
  ) async {
    final dto = await _remoteDataSource.updateRole(
      id,
      name,
      description,
      permissionIds,
    );
    return dto.toEntity();
  }

  @override
  Future<PermissionEntity> createPermission(
    String name,
    String description,
    String module,
    String restaurantId,
  ) async {
    final dto = await _remoteDataSource.createPermission(
      name,
      description,
      module,
      restaurantId,
    );
    return dto.toEntity();
  }
}
