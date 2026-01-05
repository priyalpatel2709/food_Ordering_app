import '../../domain/entities/permission_entity.dart';

class PermissionDto {
  final String? id;
  final String name;
  final String description;
  final String module;

  const PermissionDto({
    this.id,
    required this.name,
    required this.description,
    required this.module,
  });

  factory PermissionDto.fromJson(Map<String, dynamic> json) {
    return PermissionDto(
      id: json['_id'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      module: json['module'] as String? ?? '',
    );
  }

  PermissionEntity toEntity() {
    return PermissionEntity(
      id: id,
      name: name,
      description: description,
      module: module,
    );
  }
}
