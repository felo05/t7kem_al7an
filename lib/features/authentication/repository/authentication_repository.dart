import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/storage_service/storage_service.dart';
import '../model/user_model.dart';
import 'i_authentication_repository.dart';

class AuthenticationRepository implements IAuthenticationRepository {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  @override
  Future<Either<String, UserModel>> login(String name, String password) async {
    try {
      final userSnapshot = await fireStore
          .collection(FirebaseConstants.users)
          .where(FirebaseConstants.name, isEqualTo: name)
          .where(FirebaseConstants.password, isEqualTo: password)
          .get();
      if (userSnapshot.size < 1) {
        return left("االاسم او الباسورد غلط");
      }
      final userData = userSnapshot.docs.first.data();
      UserModel user = UserModel.fromJson(userData);
      await StorageService.instance.saveUser(user);
      return right(user);
    } catch (_) {
      return left("حدث خطأ ما حاول مرة اخرى");
    }
  }

  @override
  void logout() {}
}
