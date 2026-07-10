import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:t7kem_al7an/features/admin/repository/i_admin_repository.dart";

part 'judges_assigning_state.dart';

class JudgesAssigningCubit extends Cubit<JudgesAssigningState> {
  JudgesAssigningCubit(this._repository) : super(JudgesAssigningInitial());
  final IAdminRepository _repository;

  Future<void> submit({
    required String selectedDayArabic,
    required Map<String, List<String>> judgeMappings,
  }) async {
    emit(JudgesAssigningLoading());
    try {
      await _repository.assignJudges(
        selectedDayArabic: selectedDayArabic,
        judgeMappings: judgeMappings,
      );
      emit(JudgesAssigningSuccess());
    } catch (e) {
      emit(JudgesAssigningError(e.toString()));
    }
  }
}
