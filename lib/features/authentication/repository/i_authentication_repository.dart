import 'package:dartz/dartz.dart';
import '../model/user_model.dart';

abstract interface class IAuthenticationRepository {
  Future<Either<String, UserModel>> login(String name, String password);
  void logout();
}
