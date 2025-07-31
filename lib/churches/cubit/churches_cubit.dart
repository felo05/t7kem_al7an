import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/authentication/cubit/auth_cubit.dart';

part 'churches_state.dart';

class ChurchesCubit extends Cubit<ChurchesState> {
  ChurchesCubit() : super(ChurchesInitial());
  List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
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
  Future<void> getChurches() async {
    emit(ChurchesLoading());
    try {
      final FirebaseFirestore fireStore = FirebaseFirestore.instance;

      String dayName =
      DateTime.now().day!=2
          ? days[DateTime.now().weekday - 1].toLowerCase()
          : "final";
      print(dayName);
      List<MapEntry<String, String>> result = [];
      List<Future<void>> tasks = [];

      for (String level in levels) {
        tasks.add(
          _getLevelDataWithFallback(fireStore, level, dayName, AuthCubit.name!, result),
        );
      }

      await Future.wait(tasks);

      emit(ChurchesSuccess(churches: result));
    } catch (e) {
      emit(ChurchesError(message: 'Failed to load churches'));
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
      final doc = await fireStore
          .collection(level)
          .doc(dayName.toLowerCase())
          .get();
      _extractChurchesFromDoc(doc, name, level, result);
    } catch (_) {
      try {
        final doc = await fireStore
            .collection(level)
            .doc(dayName.toLowerCase())
            .get(const GetOptions(source: Source.cache));
        _extractChurchesFromDoc(doc, name, level, result);
      } catch (_) {
      }
    }
  }
}
