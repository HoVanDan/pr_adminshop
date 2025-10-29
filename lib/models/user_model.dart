class UserModel {
  final String id;
  final String username;
  final String email;
  final String password;
  final String imageUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'imageUrl': imageUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
