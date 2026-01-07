import '../../domain/entities/user_entity.dart';
import '../../../rbac/data/models/role_dto.dart';

class UserDto {
  final String id;
  final String name;
  final String email;
  final String token;
  final String role; // fallback role
  final List<RoleDto> roles;
  final String? restaurantsId;
  final String? gender;
  final int? age;

  const UserDto({
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

  /// JSON → DTO
  factory UserDto.fromJson(Map<String, dynamic> json) {
    // 🔒 UNWRAP DATA IF NEEDED
    final data = json.containsKey('data') && json['data'] is Map
        ? json['data'] as Map<String, dynamic>
        : json;

    return UserDto(
      id: data['_id'] as String? ?? data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      token: data['token'] as String? ?? '',
      role:
          data['roleName'] as String? ?? data['role'] as String? ?? 'customer',
      // Robustly parse roles
      roles:
          (data['roles'] as List<dynamic>?)
              ?.map((e) {
                if (e is Map<String, dynamic>) return RoleDto.fromJson(e);
                if (e is Map)
                  return RoleDto.fromJson(Map<String, dynamic>.from(e));
                return null;
              })
              .whereType<RoleDto>()
              .toList() ??
          [],
      // Check both singular and plural
      restaurantsId:
          data['restaurantId'] as String? ?? data['restaurantsId'] as String?,
      gender: data['gender'] as String?,
      age: data['age'] as int?,
    );
  }

  /// DTO → JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'token': token,
      'role': role,
      'roles': roles
          .map((e) => {'_id': e.id, 'name': e.name, 'isSystem': e.isSystem})
          .toList(),
      if (restaurantsId != null) 'restaurantsId': restaurantsId,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
    };
  }

  /// DTO → Entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      token: token,
      role: role,
      roles: roles.map((e) => e.toEntity()).toList(),
      restaurantsId: restaurantsId,
      gender: gender,
      age: age,
    );
  }

  /// Entity → DTO
  factory UserDto.fromEntity(UserEntity entity) {
    return UserDto(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      token: entity.token,
      role: entity.role,
      roles: entity.roles.map((e) => RoleDto.fromEntity(e)).toList(),
      restaurantsId: entity.restaurantsId,
      gender: entity.gender,
      age: entity.age,
    );
  }

  @override
  String toString() =>
      'UserDto(id: $id, name: $name, email: $email, roles: ${roles.length})';
}
