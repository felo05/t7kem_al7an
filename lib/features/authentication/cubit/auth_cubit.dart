import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../user.dart';
import '/core/constants/firebase.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void login(
    String name,
    String pass,
  ) async {
    emit(AuthLoading());
    name = name.trim();

    try {
      final FirebaseFirestore fireStore = FirebaseFirestore.instance;

      final userSnapshot = await fireStore
          .collection(Firebase.users)
          .where(Firebase.name, isEqualTo: name)
          .where("pass", isEqualTo: pass)
          .get();

      if (userSnapshot.size < 1) {
        emit(AuthError(message: "االاسم او الباسورد غلط"));
        return;
      }

      final userData = userSnapshot.docs.first.data();
      User user = User.fromJson(userData);
      await StorageService.instance.saveUser(user);
      emit(AuthSuccess(user: user));

    } catch (e) {
      emit(AuthError(message: "في مشكلة جرب تاني"));
    }
  }
}
