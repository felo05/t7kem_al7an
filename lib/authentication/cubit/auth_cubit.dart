import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../constants/firebase.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  List<String> days = [
    'Monday',
    'Tuesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  List<String> levels = [
    "kg1",
    "kg2",
    "kgF",
    "kgG",
    "oulaTanya1",
    "oulaTanya2",
    "oulaTanyaF",
    "oulaTanyaG",
    "taltaRaba1",
    "taltaRaba2",
    "taltaRabaF",
    "taltaRabaG",
    "khamsaSadsa1",
    "khamsaSadsa2",
    "khamsaSadsaF",
    "khamsaSadsaG"
  ];

  static String? name;
  void login(String name) async {
    name = name.trim();
    AuthCubit.name = name;
    String dayName = "saturday";
    List<MapEntry<String, String>> result = [];

    try {
      emit(AuthLoading());
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

      if (userData["isAdmin"] == true) {
        emit(AuthSuccess(isAadmin: true));
        return;
      }

      List<Future<void>> tasks = [];

      for (String level in levels) {
        tasks.add(
          _getLevelDataWithFallback(fireStore, level, dayName, name, result),
        );
      }

      await Future.wait(tasks);

      emit(AuthSuccess(data: result));
    } catch (e) {
      emit(AuthError(message: "في مشكلة في الاتصال أو البيانات"));
    }
  }
  void _extractChurchesFromDoc(
      DocumentSnapshot doc,
      String name,
      String level,
      List<MapEntry<String, String>> result,
      ) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) return;

    final judges = data["judges"] as List<dynamic>? ?? [];
    final churches = data["churches"] as List<dynamic>? ?? [];

    if (judges.contains(name.trim())) {
      for (final church in churches) {
        result.add(MapEntry(church, level));
      }
    }
  }

  Future<void> _getLevelDataWithFallback(
      FirebaseFirestore fireStore,
      String level,
      String dayName,
      String name,
      List<MapEntry<String, String>> result,
      ) async {
    try {
      // حاول الاتصال أونلاين
      final doc = await fireStore
          .collection(level)
          .doc(dayName.toLowerCase())
          .get();
      _extractChurchesFromDoc(doc, name, level, result);
    } catch (_) {
      try {
        // fallback للكاش
        final doc = await fireStore
            .collection(level)
            .doc(dayName.toLowerCase())
            .get(const GetOptions(source: Source.cache));
        _extractChurchesFromDoc(doc, name, level, result);
      } catch (_) {
        // فشل حتى من الكاش → تجاهل
      }
    }
  }

}
