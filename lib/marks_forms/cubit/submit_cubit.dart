import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../authentication/cubit/auth_cubit.dart';
import '../../constants/al7an.dart';

part 'submit_state.dart';

class SubmitCubit extends Cubit<SubmitState> {
  SubmitCubit() : super(SubmitInitial());

  void kg1(
      String churchName,
      List<String> al7anList,
      List<TextEditingController> controllers1,
      List<TextEditingController> controllers2,
      List<TextEditingController> controllers3,
      List<TextEditingController> controllers4,
      TextEditingController totalController,
      TextEditingController slokController,
      bool isKg,
      Future<void> Function() onPressed) async {
    emit(SubmitLoading());
    try {
      onPressed();
      if ((int.tryParse(slokController.text) ?? 21) > 10 ||
          (int.tryParse(controllers1[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers1[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers1[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers2[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers3[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers4[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers4[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers4[2].text) ?? 21) > 10) {
        emit(SubmitFailure("اتاكد من الارقام"));
        return;
      }
      if (totalController.text.isEmpty || slokController.text.isEmpty) {
        emit(SubmitFailure("كمل باقى البيانات"));
        return;
      }
      Map<String, dynamic> estmara = {
        "churchName": churchName,
        "kidsTotal": totalController.text,
        "judge": AuthCubit.name
      };
      estmara["slok"] = int.tryParse(slokController.text);
      double sum = 0;
      sum += int.tryParse(slokController.text) ?? 10;
      for (TextEditingController controller in [
        ...controllers1,
        ...controllers2,
        ...controllers3,
        ...controllers4
      ]) {
        if (controller.text.isEmpty) {
          emit(SubmitFailure("كمل باقى البيانات"));
          return;
        }

        sum += int.tryParse(controller.text) ?? 0;
      }
      estmara[al7anList[0]] = {
        Al7an.tslem: controllers1[0].text,
        Al7an.tempo: controllers1[1].text,
        Al7an.ro7ania: controllers1[2].text
      };
      estmara[al7anList[1]] = {
        Al7an.tslem: controllers2[0].text,
        Al7an.tempo: controllers2[1].text,
        Al7an.ro7ania: controllers2[2].text
      };
      estmara[al7anList[2]] = {
        Al7an.tslem: controllers3[0].text,
        Al7an.tempo: controllers3[1].text,
        Al7an.ro7ania: controllers3[2].text
      };
      estmara[al7anList[3]] = {
        Al7an.tslem: controllers4[0].text,
        Al7an.tempo: controllers4[1].text,
        Al7an.ro7ania: controllers4[2].text
      };

      estmara["total"] = sum;
      estmara["percent"] = sum / 174;
      emit(SubmitSuccess());

      final FirebaseFirestore fireStore = FirebaseFirestore.instance;
      await fireStore
          .collection(isKg ? "kg1Results" : "oulaTanya1Results")
          .add(estmara);
    } catch (e) {
      emit(SubmitFailure(e.toString()));
    }
  }

  void kg2(
      List<String> al7anList,
      List<TextEditingController> controllers1,
      List<TextEditingController> controllers2,
      List<TextEditingController> controllers3,
      List<TextEditingController> controllers4,
      List<TextEditingController> controllers5,
      List<TextEditingController> controllers6,
      TextEditingController totalController,
      TextEditingController slokController,
      bool isKg,
      String churchName,
      Future<void> Function() onPressed) async {
    emit(SubmitLoading());
    try {
      onPressed();
      if (totalController.text.isEmpty || slokController.text.isEmpty) {
        emit(SubmitFailure("كمل باقى البيانات"));
        return;
      }
      if ((int.tryParse(slokController.text) ?? 21) > 10 ||
          (int.tryParse(controllers1[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers1[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers1[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers2[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers3[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers4[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers4[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers4[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers5[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers5[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers5[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers6[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers6[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers6[2].text) ?? 21) > 10) {
        emit(SubmitFailure("اتاكد من الارقام"));
        return;
      }
      double sum = 0;
      sum += int.tryParse(slokController.text) ?? 10;

      for (var controller in [
        ...controllers1,
        ...controllers2,
        ...controllers3,
        ...controllers4,
        ...controllers5,
        ...controllers6
      ]) {
        if (controller.text.isEmpty) {
          emit(SubmitFailure("كمل باقى البيانات"));
          return;
        }

        sum += int.tryParse(controller.text) ?? 0;
      }
      Map<String, dynamic> estmara = {
        "churchName": churchName,
        "kidsTotal": totalController.text,
        "judge": AuthCubit.name
      };
      estmara["slok"] = int.tryParse(slokController.text);
      estmara[al7anList[0]] = {
        Al7an.tslem: controllers1[0].text,
        Al7an.tempo: controllers1[1].text,
        Al7an.ro7ania: controllers1[2].text
      };
      estmara[al7anList[1]] = {
        Al7an.tslem: controllers2[0].text,
        Al7an.tempo: controllers2[1].text,
        Al7an.ro7ania: controllers2[2].text
      };
      estmara[al7anList[2]] = {
        Al7an.tslem: controllers3[0].text,
        Al7an.tempo: controllers3[1].text,
        Al7an.ro7ania: controllers3[2].text
      };
      estmara[al7anList[3]] = {
        Al7an.tslem: controllers4[0].text,
        Al7an.tempo: controllers4[1].text,
        Al7an.ro7ania: controllers4[2].text
      };
      estmara[al7anList[4]] = {
        Al7an.tslem: controllers5[0].text,
        Al7an.tempo: controllers5[1].text,
        Al7an.ro7ania: controllers5[2].text
      };
      estmara[al7anList[5]] = {
        Al7an.tslem: controllers6[0].text,
        Al7an.tempo: controllers6[1].text,
        Al7an.ro7ania: controllers6[2].text
      };

      estmara["total"] = sum;
      estmara["percent"] = sum /= 256;
      emit(SubmitSuccess());

      final FirebaseFirestore fireStore = FirebaseFirestore.instance;
      await fireStore
          .collection(isKg ? "kg2Results" : "oulaTanya2Results")
          .add(estmara);
    } catch (e) {
      emit(SubmitFailure(e.toString()));
    }
  }

  void talta1(
      String churchName,
      List<String> al7anList,
      List<TextEditingController> controllers1,
      List<TextEditingController> controllers2,
      List<TextEditingController> controllers3,
      List<TextEditingController> controllers4,
      TextEditingController totalController,
      TextEditingController copticReadingController,
      TextEditingController taksController,
      TextEditingController slokController,
      bool isTalta,
      List<bool> bool1,
      List<bool> bool2,
      List<bool> bool3,
      List<bool> bool4,
      Future<void> Function() onPressed) async {
    try {
      emit(SubmitLoading());
      onPressed();
      if ((int.tryParse(copticReadingController.text) ?? 21) > 5 ||
          (int.tryParse(taksController.text) ?? 21) > 4 ||
          (int.tryParse(slokController.text) ?? 21) > 10 ||
          (int.tryParse(controllers1[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers1[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers1[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers1[3].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers2[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[3].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers3[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[3].text) ?? 21) > 10 ||
          (int.tryParse(controllers4[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers4[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers4[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers4[3].text) ?? 21) > 10) {
        emit(SubmitFailure("اتاكد من الارقام"));
        return;
      }
      double sum = 0;
      sum += int.tryParse(slokController.text) ?? 10;

      if (totalController.text.isEmpty ||
          copticReadingController.text.isEmpty ||
          taksController.text.isEmpty ||
          slokController.text.isEmpty) {
        emit(SubmitFailure("كمل باقى البيانات"));
        return;
      }
      for (var controller in [
        ...controllers1,
        ...controllers2,
        ...controllers3,
        ...controllers4,
      ]) {
        if (controller.text.isEmpty) {
          emit(SubmitFailure("كمل باقى البيانات"));
          return;
        }

        sum += int.tryParse(controller.text) ?? 0;
      }
      Map<String, dynamic> estmara = {
        "churchName": churchName,
        "judge": AuthCubit.name,
        "kidsTotal": totalController.text,
      };
      estmara["slok"] = int.tryParse(slokController.text);

      estmara[al7anList[0]] = {
        Al7an.tslem: controllers1[0].text,
        Al7an.tempo: controllers1[1].text,
        Al7an.ro7ania: controllers1[2].text,
        Al7an.copticSpelling: controllers1[3].text,
        Al7an.df: bool1[0],
        Al7an.treanto: bool1[1],
        Al7an.hzat: bool1[2]
      };
      estmara[al7anList[1]] = {
        Al7an.tslem: controllers2[0].text,
        Al7an.tempo: controllers2[1].text,
        Al7an.ro7ania: controllers2[2].text,
        Al7an.copticSpelling: controllers2[3].text,
        Al7an.df: bool2[0],
        Al7an.treanto: bool2[1],
        Al7an.hzat: bool2[2]
      };
      estmara[al7anList[2]] = {
        Al7an.tslem: controllers3[0].text,
        Al7an.tempo: controllers3[1].text,
        Al7an.ro7ania: controllers3[2].text,
        Al7an.copticSpelling: controllers3[3].text,
        Al7an.df: bool3[0],
        Al7an.treanto: bool3[1],
        Al7an.hzat: bool3[2]
      };
      estmara[al7anList[3]] = {
        Al7an.tslem: controllers4[0].text,
        Al7an.tempo: controllers4[1].text,
        Al7an.ro7ania: controllers4[2].text,
        Al7an.copticSpelling: controllers4[3].text,
        Al7an.df: bool4[0],
        Al7an.treanto: bool4[1],
        Al7an.hzat: bool4[2]
      };

      sum += bool1[0] ? .5 : 0;
      sum += bool1[1] ? .5 : 0;
      sum += !bool1[2] ? 1 : 0;
      sum += bool2[0] ? .5 : 0;
      sum += bool2[1] ? .5 : 0;
      sum += !bool2[2] ? 1 : 0;
      sum += bool3[0] ? .5 : 0;
      sum += bool3[1] ? .5 : 0;
      sum += !bool3[2] ? 1 : 0;
      sum += bool4[0] ? .5 : 0;
      sum += bool4[1] ? .5 : 0;
      sum += !bool4[2] ? 1 : 0;
      sum += int.parse(taksController.text);
      estmara["taks"] = int.tryParse(taksController.text);

      sum += int.parse(copticReadingController.text);
      estmara["copticReading"] = int.parse(copticReadingController.text);
      estmara["total"] = sum;
      estmara["percent"] = sum / 227;
      emit(SubmitSuccess());

      final FirebaseFirestore fireStore = FirebaseFirestore.instance;
      await fireStore
          .collection(isTalta ? "taltaRaba1Results" : "khamsaSadsa1Results")
          .add(estmara);
    } catch (e) {
      emit(SubmitFailure(e.toString()));
    }
  }

  void talta2(
      String churchName,
      List<String> al7anList,
      List<TextEditingController> controllers1,
      List<TextEditingController> controllers2,
      List<TextEditingController> controllers3,
      List<TextEditingController> controllers4,
      List<TextEditingController> controllers5,
      List<TextEditingController> controllers6,
      TextEditingController taksController,
      TextEditingController totalController,
      TextEditingController slokController,
      bool isTalta,
      List<bool> bool1,
      List<bool> bool2,
      List<bool> bool3,
      List<bool> bool4,
      List<bool> bool5,
      List<bool> bool6,
      Future<void> Function() onPressed) async {
    emit(SubmitLoading());
    try {
      onPressed();
      if ((int.tryParse(taksController.text) ?? 21) > 6 ||
          (int.tryParse(slokController.text) ?? 21) > 10 ||
          (int.tryParse(controllers1[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers1[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers1[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers1[3].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers2[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[3].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers3[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[3].text) ?? 21) > 10 ||
          (int.tryParse(controllers4[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers4[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers4[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers4[3].text) ?? 21) > 10 ||
          (int.tryParse(controllers5[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers5[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers5[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers5[3].text) ?? 21) > 10 ||
          (int.tryParse(controllers6[0].text) ?? 21) > 20 ||
          (int.tryParse(controllers6[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers6[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers6[3].text) ?? 21) > 10) {
        emit(SubmitFailure("اتاكد من الارقام"));
        return;
      }
      if (totalController.text.isEmpty ||
          taksController.text.isEmpty ||
          slokController.text.isEmpty) {
        emit(SubmitFailure("كمل باقى البيانات"));
        return;
      }
      double sum = 0;
      sum += int.tryParse(slokController.text) ?? 10;

      for (var controller in [
        ...controllers1,
        ...controllers2,
        ...controllers3,
        ...controllers4,
        ...controllers5,
        ...controllers6
      ]) {
        if (controller.text.isEmpty) {
          emit(SubmitFailure("كمل باقى البيانات"));
          return;
        }

        sum += int.tryParse(controller.text) ?? 0;
      }
      Map<String, dynamic> estmara = {
        "judge": AuthCubit.name,
        "churchName": churchName,
        "kidsTotal": totalController.text,
      };
      estmara["slok"] = int.tryParse(slokController.text);
      estmara[al7anList[0]] = {
        Al7an.tslem: controllers1[0].text,
        Al7an.tempo: controllers1[1].text,
        Al7an.ro7ania: controllers1[2].text,
        Al7an.copticSpelling: controllers1[3].text,
        Al7an.df: bool1[0],
        Al7an.treanto: bool1[1],
        Al7an.hzat: bool1[2]
      };
      estmara[al7anList[1]] = {
        Al7an.tslem: controllers2[0].text,
        Al7an.tempo: controllers2[1].text,
        Al7an.ro7ania: controllers2[2].text,
        Al7an.copticSpelling: controllers2[3].text,
        Al7an.df: bool2[0],
        Al7an.treanto: bool2[1],
        Al7an.hzat: bool2[2]
      };
      estmara[al7anList[2]] = {
        Al7an.tslem: controllers3[0].text,
        Al7an.tempo: controllers3[1].text,
        Al7an.ro7ania: controllers3[2].text,
        Al7an.copticSpelling: controllers3[3].text,
        Al7an.df: bool3[0],
        Al7an.treanto: bool3[1],
        Al7an.hzat: bool3[2]
      };
      estmara[al7anList[3]] = {
        Al7an.tslem: controllers4[0].text,
        Al7an.tempo: controllers4[1].text,
        Al7an.ro7ania: controllers4[2].text,
        Al7an.copticSpelling: controllers4[3].text,
        Al7an.df: bool4[0],
        Al7an.treanto: bool4[1],
        Al7an.hzat: bool4[2]
      };
      estmara[al7anList[4]] = {
        Al7an.tslem: controllers5[0].text,
        Al7an.tempo: controllers5[1].text,
        Al7an.ro7ania: controllers5[2].text,
        Al7an.copticSpelling: controllers5[3].text,
        Al7an.df: bool5[0],
        Al7an.treanto: bool5[1],
        Al7an.hzat: bool5[2]
      };
      estmara[al7anList[5]] = {
        Al7an.tslem: controllers6[0].text,
        Al7an.tempo: controllers6[1].text,
        Al7an.ro7ania: controllers6[2].text,
        Al7an.copticSpelling: controllers6[3].text,
        Al7an.df: bool6[0],
        Al7an.treanto: bool6[1],
        Al7an.hzat: bool6[2]
      };

      sum += bool1[0] ? .5 : 0;
      sum += bool1[1] ? .5 : 0;
      sum += !bool1[2] ? 1 : 0;
      sum += bool2[0] ? .5 : 0;
      sum += bool2[1] ? .5 : 0;
      sum += !bool2[2] ? 1 : 0;
      sum += bool3[0] ? .5 : 0;
      sum += bool3[1] ? .5 : 0;
      sum += !bool3[2] ? 1 : 0;
      sum += bool4[0] ? .5 : 0;
      sum += bool4[1] ? .5 : 0;
      sum += !bool4[2] ? 1 : 0;
      sum += bool5[0] ? .5 : 0;
      sum += bool5[1] ? .5 : 0;
      sum += !bool5[2] ? 1 : 0;
      sum += bool6[0] ? .5 : 0;
      sum += bool6[1] ? .5 : 0;
      sum += !bool6[2] ? 1 : 0;
      sum += int.parse(taksController.text);
      estmara["taks"] = int.parse(taksController.text);
      estmara["total"] = sum;

      estmara["percent"] = sum / 328;
      emit(SubmitSuccess());

      final FirebaseFirestore fireStore = FirebaseFirestore.instance;
      await fireStore
          .collection(isTalta ? "taltaRaba2Results" : "khamsaSadsa2Results")
          .add(estmara);
    } catch (e) {
      emit(SubmitFailure(e.toString()));
    }
  }

  void mohobenIndividual(
      String churchName,
      int level,
      List<String> al7anList,
      List<TextEditingController> controllers1,
      List<TextEditingController> controllers2,
      List<TextEditingController> controllers3,
      List<bool> bool1,
      List<bool> bool2,
      List<bool> bool3,
      Future<void> Function() onPressed) async {
    emit(SubmitLoading());
    try {
      onPressed();
      if ((int.tryParse(controllers1[0].text) ?? 21) > 15 ||
          (int.tryParse(controllers1[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers1[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[0].text) ?? 21) > 15 ||
          (int.tryParse(controllers2[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[0].text) ?? 21) > 15 ||
          (int.tryParse(controllers3[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[2].text) ?? 21) > 10) {
        emit(SubmitFailure("اتاكد من الارقام"));
        return;
      }
      double factor = 1;
      double sum = 0;
      for (var controller in controllers3) {
        if (controller.text.isEmpty) {
          emit(SubmitFailure("كمل باقى البيانات"));
          return;
        }
        sum += int.parse(controller.text);
      }
      sum += bool3[0] ? 1 : 0;
      sum += bool3[1] ? 1 : 0;
      factor = (sum >= 50 && sum <= 53)
          ? 1.01
          : (sum >= 54 && sum <= 56)
              ? 1.02
              : (sum >= 57 && sum <= 59)
                  ? 1.05
                  : (sum >= 60 && sum <= 61)
                      ? 1.07
                      : 1;
      for (var controller in [
        ...controllers1,
        ...controllers2,
      ]) {
        if (controller.text.isEmpty) {
          emit(SubmitFailure("كمل باقى البيانات"));
          return;
        }

        sum += int.tryParse(controller.text) ?? 0;
      }
      Map<String, dynamic> estmara = {
        "churchName": churchName,
        "judge": AuthCubit.name,
        al7anList[0]: {
          Al7an.tslem: controllers1[0].text,
          Al7an.copticReading: controllers1[1].text,
          Al7an.ro7ania: controllers1[2].text,
          Al7an.taks: bool1[0],
          Al7an.df: bool1[1],
        },
        al7anList[1]: {
          Al7an.tslem: controllers2[0].text,
          Al7an.copticReading: controllers2[1].text,
          Al7an.ro7ania: controllers2[2].text,
          Al7an.taks: bool2[0],
          Al7an.df: bool2[1],
        },
        al7anList[2]: {
          Al7an.tslem: controllers3[0].text,
          Al7an.copticReading: controllers3[1].text,
          Al7an.ro7ania: controllers3[2].text,
          Al7an.taks: bool3[0],
          Al7an.df: bool3[1]
        },
      };

      sum += bool1[0] ? 1 : 0;
      sum += bool1[1] ? 1 : 0;
      sum += bool2[0] ? 1 : 0;
      sum += bool2[1] ? 1 : 0;

      sum *= factor;
      estmara["total"] = sum;
      estmara["percentage"] = sum / 111;
      emit(SubmitSuccess());
      final FirebaseFirestore fireStore = FirebaseFirestore.instance;
      await fireStore
          .collection(level == 0
              ? "kgFResults"
              : level == 1
                  ? "oulaTanyaFResults"
                  : level == 2
                      ? "taltaRabaFResults"
                      : "khamsaSadsaFResults")
          .add(estmara);
    } catch (e) {
      emit(SubmitFailure(e.toString()));
    }
  }

  void mohobenGroup(
      String churchName,
      int level,
      List<String> al7anList,
      List<TextEditingController> controllers1,
      List<TextEditingController> controllers2,
      List<TextEditingController> controllers3,
      TextEditingController totalController,
      TextEditingController slokController,
      List<bool> bool1,
      List<bool> bool2,
      List<bool> bool3,
      Future<void> Function() onPressed) async {
    try {
      emit(SubmitLoading());
      onPressed();
      if ((int.tryParse(slokController.text) ?? 21) > 10 ||
          (int.tryParse(controllers1[0].text) ?? 21) > 15 ||
          (int.tryParse(controllers1[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers1[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers1[3].text) ?? 21) > 10 ||
          (int.tryParse(controllers1[4].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[0].text) ?? 21) > 15 ||
          (int.tryParse(controllers2[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[3].text) ?? 21) > 10 ||
          (int.tryParse(controllers2[4].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[0].text) ?? 21) > 15 ||
          (int.tryParse(controllers3[1].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[2].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[3].text) ?? 21) > 10 ||
          (int.tryParse(controllers3[4].text) ?? 21) > 10) {
        emit(SubmitFailure("اتاكد من الارقام"));
        return;
      }
      if (totalController.text.isEmpty || slokController.text.isEmpty) {
        emit(SubmitFailure("كمل باقى البيانات"));
        return;
      }
      double factor = 1;
      double sum = 0;
      for (var controller in controllers3) {
        if (controller.text.isEmpty) {
          emit(SubmitFailure("كمل باقى البيانات"));
          return;
        }
        sum += int.parse(controller.text);
      }
      sum += bool3[0] ? 1 : 0;
      sum += bool3[1] ? 1 : 0;
      factor = (sum >= 50 && sum <= 53)
          ? 1.01
          : (sum >= 54 && sum <= 56)
              ? 1.02
              : (sum >= 57 && sum <= 59)
                  ? 1.05
                  : (sum >= 60 && sum <= 61)
                      ? 1.07
                      : 1;

      for (var controller in [
        ...controllers1,
        ...controllers2,
      ]) {
        if (controller.text.isEmpty) {
          emit(SubmitFailure("كمل باقى البيانات"));
          return;
        }

        sum += int.tryParse(controller.text) ?? 0;
      }
      Map<String, dynamic> estmara = {
        "churchName": churchName,
        "kidsTotal": totalController.text,
        "judge": AuthCubit.name
      };
      estmara[al7anList[0]] = {
        Al7an.tslem: controllers1[0].text,
        Al7an.tempo: controllers1[1].text,
        Al7an.tnas2: controllers1[2].text,
        Al7an.copticReading: controllers1[3].text,
        Al7an.ro7ania: controllers1[4].text,
        Al7an.taks: bool1[0],
        Al7an.df: bool1[1],
      };
      estmara[al7anList[1]] = {
        Al7an.tslem: controllers2[0].text,
        Al7an.tempo: controllers2[1].text,
        Al7an.tnas2: controllers2[2].text,
        Al7an.copticReading: controllers2[3].text,
        Al7an.ro7ania: controllers2[4].text,
        Al7an.taks: bool2[0],
        Al7an.df: bool2[1],
      };
      estmara[al7anList[2]] = {
        Al7an.tslem: controllers3[0].text,
        Al7an.tempo: controllers3[1].text,
        Al7an.tnas2: controllers3[2].text,
        Al7an.copticReading: controllers3[3].text,
        Al7an.ro7ania: controllers3[4].text,
        Al7an.taks: bool3[0],
        Al7an.df: bool3[1],
      };

      sum += bool1[0] ? 1 : 0;
      sum += bool1[1] ? 1 : 0;
      sum += bool2[0] ? 1 : 0;
      sum += bool2[1] ? 1 : 0;

      sum *= factor;
      sum += int.tryParse(slokController.text) ?? 10;
      estmara["total"] = sum;
      estmara["slok"] = int.tryParse(slokController.text);
      estmara["percent"] = sum / 196;
      emit(SubmitSuccess());

      final FirebaseFirestore fireStore = FirebaseFirestore.instance;
      await fireStore
          .collection(level == 0
              ? "kgGResults"
              : level == 1
                  ? "oulaTanyaGResults"
                  : level == 2
                      ? "taltaRabaGResults"
                      : "khamsaSadsaGResults")
          .add(estmara);
    } catch (e) {
      emit(SubmitFailure(e.toString()));
    }
  }
}
