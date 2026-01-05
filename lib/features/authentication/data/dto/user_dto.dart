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
    return UserDto(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      token: json['token'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      roles:
          (json['roles'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>() // 🔒 SAFETY
              .map(RoleDto.fromJson)
              .toList() ??
          [],
      restaurantsId: json['restaurantsId'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
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
      roles: const [],
      restaurantsId: entity.restaurantsId,
      gender: entity.gender,
      age: entity.age,
    );
  }

  @override
  String toString() =>
      'UserDto(id: $id, name: $name, email: $email, roles: ${roles.length})';
}
