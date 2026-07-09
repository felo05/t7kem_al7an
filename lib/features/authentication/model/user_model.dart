import 'package:t7kem_al7an/core/constants/firebase_constants.dart';

class UserModel {
  final String name;
  final bool isAdmin;
  final String? password;
  final String? docId;

  UserModel({required this.name, this.isAdmin = false, this.password, this.docId});

  factory UserModel.fromJson(Map<String, dynamic> data, {String? docId}) {
    return UserModel(
      name: data[FirebaseConstants.name],
      isAdmin: data[FirebaseConstants.isAdmin] == true,
      password: data[FirebaseConstants.password],
      docId: docId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.name: name,
      FirebaseConstants.isAdmin: isAdmin,
      FirebaseConstants.password: password,
    };
  }
}
