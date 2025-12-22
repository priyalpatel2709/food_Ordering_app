import '../../domain/entities/user_entity.dart';

/// User DTO - for API communication
/// TODO: When build_runner is fixed, restore Freezed + JSON Serializable code generation
class UserDto {
  final String id;
  final String name;
  final String email;
  final String token;
  final String? restaurantsId;

  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    this.restaurantsId,
  });

  /// Manual JSON deserialization
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
      restaurantsId: json['restaurantsId'] as String?,
    );
  }

  /// Manual JSON serialization
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'token': token,
      if (restaurantsId != null) 'restaurantsId': restaurantsId,
    };
  }

  /// Convert DTO to Entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      token: token,
      restaurantsId: restaurantsId,
    );
  }

  /// Convert Entity to DTO
  factory UserDto.fromEntity(UserEntity entity) {
    return UserDto(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      token: entity.token,
      restaurantsId: entity.restaurantsId,
    );
  }

  @override
  String toString() => 'UserDto(id: $id, name: $name, email: $email)';
}
