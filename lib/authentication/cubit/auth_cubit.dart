import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../constants/firebase.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());


  static String? name;
  void login(String name, String pass,) async {
    emit(AuthLoading());
    name = name.trim();
    AuthCubit.name = name;


    try {
      final FirebaseFirestore fireStore = FirebaseFirestore.instance;

      final userSnapshot = await fireStore
          .collection(Firebase.users)
          .where(Firebase.name, isEqualTo: name)
          .get();

      if (userSnapshot.size < 1) {
        emit(AuthError(message: "اكتب الاسم صح"));
        return;
      }

      final userData = userSnapshot.docs.first.data();
      if (userData["pass"] != pass) {
        emit(AuthError(message: "الباسورد غلط"));
        return;
      }
      if (userData["isAdmin"]??false == true) {
        emit(AuthSuccess(isAadmin: true));
      }
      else{
        emit(AuthSuccess(isAadmin:false));

      }


    } catch (e) {
      emit(AuthError(message: "في مشكلة في الاتصال أو البيانات"));
    }
  }


}
