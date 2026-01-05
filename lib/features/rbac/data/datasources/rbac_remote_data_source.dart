import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../authentication/data/dto/user_dto.dart';
import '../models/role_dto.dart';
import '../models/permission_dto.dart';

abstract class RbacRemoteDataSource {
  Future<List<RoleDto>> getRoles();
  Future<List<PermissionDto>> getPermissions();
  Future<RoleDto> createRole(
    String name,
    String description,
    List<String> permissionIds,
  );
  Future<void> assignRoles(String userId, List<String> roleIds);
  Future<List<UserDto>> getStaffUsers();
  Future<RoleDto> updateRole(
    String id,
    String? name,
    String? description,
    List<String> permissionIds,
  );
  Future<PermissionDto> createPermission(
    String name,
    String description,
    String module,
  );
}

class RbacRemoteDataSourceImpl implements RbacRemoteDataSource {
  final DioClient _dioClient;

  RbacRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<RoleDto>> getRoles() async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.rbac}/${ApiConstants.roles}',
    );
    // Guide says: { status: success, results: 5, data: [ ...Role[] ] }
    final data = response.data['data'] as List;
    return data
        .map((e) => RoleDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PermissionDto>> getPermissions() async {
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.rbac}/${ApiConstants.permissions}',
    );
    // Guide says: { status: success, data: [ ...Permission[] ], grouped: { ... } }
    final data = response.data['data'] as List;
    return data
        .map((e) => PermissionDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RoleDto> createRole(
    String name,
    String description,
    List<String> permissionIds,
  ) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.rbac}/${ApiConstants.roles}',
      data: {
        'name': name,
        'description': description,
        'permissions': permissionIds,
      },
    );
    return RoleDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> assignRoles(String userId, List<String> roleIds) async {
    await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.rbac}${ApiConstants.assignRole}',
      data: {'userId': userId, 'roleIds': roleIds},
    );
  }

  @override
  Future<List<UserDto>> getStaffUsers() async {
    // Assuming endpoint to get staff
    final response = await _dioClient.get(
      '${ApiConstants.v1}${ApiConstants.user}/restaurant/restaurant_123',
    );
    return (response.data as List)
        .map((e) => UserDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RoleDto> updateRole(
    String id,
    String? name,
    String? description,
    List<String> permissionIds,
  ) async {
    final response = await _dioClient.put(
      '${ApiConstants.v1}${ApiConstants.rbac}/${ApiConstants.roles}/$id',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        'permissions': permissionIds,
      },
    );
    return RoleDto.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PermissionDto> createPermission(
    String name,
    String description,
    String module,
  ) async {
    final response = await _dioClient.post(
      '${ApiConstants.v1}${ApiConstants.rbac}/${ApiConstants.permissions}',
      data: {'name': name, 'description': description, 'module': module},
    );
    return PermissionDto.fromJson(response.data as Map<String, dynamic>);
  }
}
