class PermissionEntity {
  final String? id;
  final String name; // e.g. "ORDER.CREATE"
  final String description;
  final String module; // "ORDER", "USER", etc.

  const PermissionEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.module,
  });

  factory PermissionEntity.fromJson(Map<String, dynamic> json) {
    return PermissionEntity(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      module: json['module'] as String,
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          module == other.module;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ description.hashCode ^ module.hashCode;
}
