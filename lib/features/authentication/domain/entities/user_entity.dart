import '../../../rbac/domain/entities/role_entity.dart';

/// User Entity - Pure domain model
/// TODO: When build_runner is fixed, restore Freezed code generation
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String token;
  final String role; // 'customer' or 'staff' (Deprecated but kept for now)
  final List<RoleEntity> roles;
  final String? restaurantsId;
  final String? gender;
  final int? age;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.role,
    this.roles = const [],
    this.restaurantsId,
    this.gender,
    this.age,
  });

  /// Computed property to get all permissions from all assigned roles
  Set<String> get allPermissions {
    final perms = <String>{};
    for (final role in roles) {
      for (final p in role.permissions) {
        perms.add(p.name);
      }
    }
    return perms;
  }

  /// Check if user has specific permission
  bool hasPermission(String permission) {
    if (allPermissions.contains('SUPER_ADMIN_ALL_ACCESS')) return true;
    return allPermissions.contains(permission);
  }

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    String? role,
    List<RoleEntity>? roles,
    String? restaurantsId,
    String? gender,
    int? age,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      role: role ?? this.role,
      roles: roles ?? this.roles,
      restaurantsId: restaurantsId ?? this.restaurantsId,
      gender: gender ?? this.gender,
      age: age ?? this.age,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          token == other.token &&
          role == other.role &&
          // roles == other.roles && // List equality might be tricky, usually fine if reference diff
          restaurantsId == other.restaurantsId &&
          gender == other.gender &&
          age == other.age;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      token.hashCode ^
      role.hashCode ^
      // roles.hashCode ^
      restaurantsId.hashCode ^
      gender.hashCode ^
      age.hashCode;

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, email: $email, token: $token, role: $role, roles: ${roles.length}, restaurantsId: $restaurantsId, gender: $gender, age: $age)';
  }
}
