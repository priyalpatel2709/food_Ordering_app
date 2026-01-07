import 'package:hive/hive.dart';
import 'permission.dart';

part 'role.g.dart';

@HiveType(typeId: 2)
class Role extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final List<Permission> permissions;

  @HiveField(4)
  final String? restaurantId;

  Role({
    this.id,
    required this.name,
    required this.description,
    required this.permissions,
    this.restaurantId,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    var permissionsList = <Permission>[];
    if (json['permissions'] != null) {
      json['permissions'].forEach((v) {
        permissionsList.add(Permission.fromJson(v));
      });
    }
    return Role(
      id: json['_id'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? json['name'] ?? '',
      permissions: permissionsList,
      restaurantId: json['restaurantId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'permissions': permissions.map((v) => v.toJson()).toList(),
      'restaurantId': restaurantId,
    };
  }
}
