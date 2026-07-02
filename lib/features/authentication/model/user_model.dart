class UserModel {
  final String name;
  final bool isAdmin;

  UserModel({required this.name, this.isAdmin = false});

  factory UserModel.fromJson(Map<String, dynamic> data) {
    final nameValue = data['name'];

    return UserModel(
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
