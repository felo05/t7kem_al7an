class User {
  final String name;
  final bool isAdmin;

  User({required this.name, this.isAdmin = false});

  factory User.fromJson(Map<String, dynamic> data) {
    final nameValue = data['name'];

    return User(
      name: nameValue is String ? nameValue : '',
      isAdmin: data['isAdmin'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isAdmin': isAdmin,
    };
  }
}