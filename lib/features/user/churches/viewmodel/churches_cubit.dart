import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/features/user/repository/i_user_repository.dart';
import 'package:flutter/material.dart';
import '../../../authentication/model/user_model.dart';
import '../../marks_forms/base_marks_form.dart';
import '../model/church_levels_model.dart';

part 'churches_state.dart';

class ChurchesCubit extends Cubit<ChurchesState> {
  ChurchesCubit(this._repository) : super(ChurchesInitial());

  final IUserRepository _repository;
  final subscriptions = <StreamSubscription>[];
  final latestDocs = <String, DocumentSnapshot<Map<String, dynamic>>>{};

  void start(UserModel user) {
    final dayName = ChurchLevelsModel.resolveDayName();

    for (final level in ChurchLevelsModel.levels) {
      final stream = _repository.watchLevelDay(level: level, dayName: dayName);
      subscriptions.add(stream.listen(
        (doc) {
          latestDocs[level] = doc;
          _emitFromLatest(user);
        },
        onError: (e) => emit(ChurchesError(message: e.toString())),
      ));
    }
  }

  void _emitFromLatest(UserModel user) {
    final result = <BaseMarksFormModel>[];
    for (final level in ChurchLevelsModel.levels) {
      final doc = latestDocs[level];
      if (doc == null) continue;

      final data = doc.data();
      if (data == null) continue;

      final judges = data["judges"] as List<dynamic>? ?? [];
      final churches = data["churches"] as List<dynamic>? ?? [];

      if (judges.contains(user.name.trim())) {
        for (final church in churches) {
          result
              .add(ChurchLevelsModel.levelToForm[level]!.setChurchName(church));
        }
      }
    }
    emit(ChurchesSuccess(churches: result));
  }

  @override
  Future<void> close() async {
    for (final sub in subscriptions) {
      await sub.cancel();
    }
    return super.close();
  }
}
