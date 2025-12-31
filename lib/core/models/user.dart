import 'package:hive/hive.dart';

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

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.role,
    this.restaurantsId,
    this.gender,
    this.age,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
      role: json['role'] as String? ?? 'customer',
      restaurantsId: json['restaurantId'] as String?,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'token': token,
      'role': role,
      'restaurantId': restaurantsId,
      'gender': gender,
      'age': age,
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
    );
  }
}
