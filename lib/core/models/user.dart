import 'package:hive/hive.dart';
import 'role.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String token;

  @HiveField(4)
  final String? restaurantsId;

  @HiveField(5, defaultValue: 'customer')
  final String role;

  @HiveField(6)
  final String? gender;

  @HiveField(7)
  final int? age;

  @HiveField(8)
  final List<Role>? roles;

  @HiveField(9)
  final bool? isActive;

  @HiveField(10)
  final String? deviceToken;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.role,
    this.restaurantsId,
    this.gender,
    this.age,
    this.roles,
    this.isActive,
    this.deviceToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var rolesList = <Role>[];
    if (json['roles'] != null) {
      json['roles'].forEach((v) {
        rolesList.add(Role.fromJson(v));
      });
    }

    return User(
      id: json['_id'] as String? ?? '', // Handle missing _id gracefully
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      token: json['token'] as String? ?? '',
      role:
          json['roleName'] as String? ?? json['role'] as String? ?? 'customer',
      restaurantsId: json['restaurantId'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      roles: rolesList,
      isActive: json['isActive'] as bool?,
      deviceToken: json['deviceToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'token': token,
      'role':
          role, // Mapping back to 'role' or 'roleName'? Sticking to 'role' for internal compatibility.
      'roleName': role, // Also sending roleName if needed
      'restaurantId': restaurantsId,
      'gender': gender,
      'age': age,
      'roles': roles?.map((v) => v.toJson()).toList(),
      'isActive': isActive,
      'deviceToken': deviceToken,
    };
  }

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    String? role,
    String? restaurantsId,
    List<Role>? roles,
    bool? isActive,
    String? deviceToken,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      role: role ?? this.role,
      restaurantsId: restaurantsId ?? this.restaurantsId,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
      deviceToken: deviceToken ?? this.deviceToken,
    );
  }
}
