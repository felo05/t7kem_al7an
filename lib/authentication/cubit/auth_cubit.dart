import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../constants/firebase.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  List<String> days = [
    'Monday', 'Tuesday',  'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  List<String> levels = [
    "kg1","kg2","kgF","kgG","oulaTanya1","oulaTanya2","oulaTanyaF","oulaTanyaG","taltaRaba1","taltaRaba2","taltaRabaF","taltaRabaG",
    "khamsaSadsa1","khamsaSadsa2","khamsaSadsaF","khamsaSadsaG"
  ];

static String? name;
  void login(String name)async{
    AuthCubit.name = name;
    print("[$name]");
    String dayName = "saturday";
    // days[DateTime.now().weekday - 1];
    Map<String,String> result={};
    try{
      emit(AuthLoading());

      final FirebaseFirestore fireStore = FirebaseFirestore.instance;
      final x=await fireStore
          .collection(Firebase.users).where(Firebase.name, isEqualTo: name).get();
      if(x.size>0) {
        emit(AuthError());
        return;
      }

      for(String level in levels){
        await fireStore
            .collection(level)
            .doc(dayName.toLowerCase())
            .get()
            .then((value) {


          if ((value.data()?["judges"] as List<dynamic>).contains(name.trim())) {
            for (String church in value.data()!["churches"] as List<dynamic>) {
              result[church] = level;
            }
          }
        });
      }
      emit(AuthSuccess(data: result));
      print("=================");
      print(result);


    }catch(e){
      emit(AuthError());
    }
  }
}
