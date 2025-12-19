class User {
  final String id;
  final String name;
  final String email;
  final String token;
  final String? restaurantsId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    this.restaurantsId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      token: json['token'] as String,
      restaurantsId: json['restaurantsId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'token': token,
      'restaurantsId': restaurantsId,
    };
  }
}
