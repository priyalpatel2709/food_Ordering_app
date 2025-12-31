/// User Entity - Pure domain model
/// TODO: When build_runner is fixed, restore Freezed code generation
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String token;
  final String role; // 'customer' or 'staff'
  final String? restaurantsId;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.role,
    this.restaurantsId,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    String? role,
    String? restaurantsId,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      role: role ?? this.role,
      restaurantsId: restaurantsId ?? this.restaurantsId,
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
          restaurantsId == other.restaurantsId;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      token.hashCode ^
      role.hashCode ^
      restaurantsId.hashCode;

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, email: $email, token: $token, role: $role, restaurantsId: $restaurantsId)';
  }
}
