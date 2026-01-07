import 'package:flutter/foundation.dart';
import 'permission_entity.dart';

class RoleEntity {
  final String id;
  final String name;
  final List<PermissionEntity> permissions;
  final bool isSystem;
  final String description;
  final DateTime createdAt;

  const RoleEntity({
    required this.id,
    required this.name,
    required this.permissions,
    required this.isSystem,
    // this.restaurantId,
    required this.description,
    required this.createdAt,
  });

  factory RoleEntity.fromJson(Map<String, dynamic> json) {
    return RoleEntity(
      id: json['_id'] as String,
      name: json['name'] as String,
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => PermissionEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isSystem: json['isSystem'] as bool? ?? false,
      // restaurantId: json['restaurantId'] as String?,
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoleEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          listEquals(permissions, other.permissions) &&
          isSystem == other.isSystem &&
          description == other.description;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      Object.hashAll(permissions) ^
      isSystem.hashCode ^
      description.hashCode;
}
