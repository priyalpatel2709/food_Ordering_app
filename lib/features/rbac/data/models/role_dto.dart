import '../../domain/entities/role_entity.dart';
import 'permission_dto.dart';

class RoleDto {
  final String id;
  final String name;
  final List<PermissionDto> permissions;
  final bool isSystem;
  final String description;
  final String createdAt;

  const RoleDto({
    required this.id,
    required this.name,
    required this.permissions,
    required this.isSystem,
    required this.description,
    required this.createdAt,
  });

  factory RoleDto.fromJson(Map<String, dynamic> json) {
    // 🔒 SAFETY: handle wrapped response
    final Map<String, dynamic> data = json.containsKey('data')
        ? json['data'] as Map<String, dynamic>
        : json;

    return RoleDto(
      id: data['_id'] as String,
      name: data['name'] as String? ?? '',
      permissions:
          (data['permissions'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(PermissionDto.fromJson)
              .toList() ??
          [],
      isSystem: data['isSystem'] as bool? ?? false,
      description: data['description'] as String? ?? '',
      createdAt: data['createdAt'] as String? ?? '',
    );
  }

  RoleEntity toEntity() {
    return RoleEntity(
      id: id,
      name: name,
      permissions: permissions.map((e) => e.toEntity()).toList(),
      isSystem: isSystem,
      description: description, // Assuming RoleEntity has description
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }

  factory RoleDto.fromEntity(RoleEntity entity) {
    return RoleDto(
      id: entity.id,
      name: entity.name,
      permissions: entity.permissions
          .map((e) => PermissionDto.fromEntity(e))
          .toList(),
      isSystem: entity.isSystem,
      description: entity.description,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
