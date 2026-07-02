import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../../authentication/user.dart';
import '../../marks_forms/base_marks_form.dart';

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

  Map<String, BaseMarksFormModel> levelToForm = {
    'kg1': Kg1FormModel(isKg: true, churchName: "",levelInArabic: "مرحلة حضانة المستوى الاول"),
    'kg2': Kg2FormModel(isKg: true, churchName: "",levelInArabic: "مرحلة حضانة المستوى الثانى"),
    'kgF': MohobenIndividualFormModel(level: 0, churchName: "",levelInArabic: "موهوبين فردى مرحلة حضانة"),
    'kgG': MohobenGroupFormModel(level: 0, churchName: "",levelInArabic: "موهوبين جماعى مرحلة حضانة"),
    'oulaTanya1': Kg1FormModel(isKg: false, churchName: "",levelInArabic: "مرحلة اولى وتانية المستوى الاول"),
    'oulaTanya2': Kg2FormModel(isKg: false, churchName: "",levelInArabic: "مرحلة اولى وتانية المستوى الثانى"),
    'oulaTanyaF': MohobenIndividualFormModel(level: 1, churchName: "",levelInArabic: "موهوبين فردى مرحلة اولى وتانية"),
    'oulaTanyaG': MohobenGroupFormModel(level: 1, churchName: "",levelInArabic: "موهوبين الجماعى مرحلة اولى وتانية"),
    'taltaRaba1': Talta1FormModel(isTalta: true, churchName: "",levelInArabic: "مرحلة ثالثة ورابعة المستوى الاول"),
    'taltaRaba2': Talta2FormModel(isTalta: true, churchName: "",levelInArabic: "مرحلة الثالثة ورابعة المستوى الثانى"),
    'taltaRabaF': MohobenIndividualFormModel(level: 2, churchName: "",levelInArabic: "موهوبين فردى مرحلة ثالثة ورابعة"),
    'taltaRabaG': MohobenGroupFormModel(level: 2, churchName: "",levelInArabic: "موهوبين الجماعى مرحلة ثالثة ورابعة"),
    'khamsaSadsa1': Talta1FormModel(isTalta: false, churchName: "",levelInArabic: "مرحلة خامسة وسادسة المستوى الاول"),
    'khamsaSadsa2': Talta2FormModel(isTalta: false, churchName: "",levelInArabic: "مرحلة خامسة وسادسة المستوى الثانى"),
    'khamsaSadsaF': MohobenIndividualFormModel(level: 3, churchName: "",levelInArabic: "موهوبين فردى مرحلة خامسة وسادسة"),
    'khamsaSadsaG': MohobenGroupFormModel(level: 3, churchName: "",levelInArabic: "موهوبين الجماعى مرحلة خامسة وسادسة")
  };

  Future<void> getChurches(User user) async {
    emit(ChurchesLoading());
    try {
      final FirebaseFirestore fireStore = FirebaseFirestore.instance;

      String dayName =
      DateTime.now().day!=2
          ? days[DateTime.now().weekday - 1].toLowerCase()
          : "final";
      List<BaseMarksFormModel> result = [];
      List<Future<void>> tasks = [];

      for (String level in levels) {
        tasks.add(
          _getLevelDataWithFallback(fireStore, level, dayName, user.name, result),
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
      List<BaseMarksFormModel> result,
      ) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) return;

    final judges = data["judges"] as List<dynamic>? ?? [];
    final churches = data["churches"] as List<dynamic>? ?? [];

    if (judges.contains(name.trim())) {
      for (final church in churches) {
        result.add(levelToForm[level]!.setChurchName(church));
      }
    }
  }

  Future<void> _getLevelDataWithFallback(
      FirebaseFirestore fireStore,
      String level,
      String dayName,
      String name,
      List<BaseMarksFormModel> result,
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

  Stream<List<BaseMarksFormModel>> watchChurches(User user) {
    final controller = StreamController<List<BaseMarksFormModel>>();
    final subscriptions = <StreamSubscription>[];
    final latestDocs = <String, DocumentSnapshot<Map<String, dynamic>>>{};

    String dayName =
    DateTime.now().day != 2
        ? days[DateTime.now().weekday - 1].toLowerCase()
        : "final";

    void emitFromLatest() {
      final result = <BaseMarksFormModel>[];
      for (final level in levels) {
        final doc = latestDocs[level];
        if (doc != null) {
          _extractChurchesFromDoc(doc, user.name, level, result);
        }
      }
      if (!controller.isClosed) {
        controller.add(result);
      }
    }

    for (final level in levels) {
      final stream = FirebaseFirestore.instance
          .collection(level)
          .doc(dayName.toLowerCase())
          .snapshots();
      subscriptions.add(stream.listen(
            (doc) {
          latestDocs[level] = doc;
          emitFromLatest();
        },
        onError: (error) {
          if (!controller.isClosed) {
            controller.addError(error);
          }
        },
      ));
    }

    controller.onCancel = () async {
      for (final sub in subscriptions) {
        await sub.cancel();
      }
    };

    return controller.stream;
  }
}
