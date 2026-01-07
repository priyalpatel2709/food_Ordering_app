import 'package:hive/hive.dart';

part 'permission.g.dart';

@HiveType(typeId: 1)
class Permission extends HiveObject {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String module;

  @HiveField(4)
  final String? restaurantId;

  Permission({
    this.id,
    required this.name,
    required this.description,
    required this.module,
    this.restaurantId,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['_id'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      module: json['module'] as String? ?? '',
      restaurantId: json['restaurantId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'module': module,
      'restaurantId': restaurantId,
    };
  }
}
