import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


part 'submit_state.dart';

class SubmitCubit extends Cubit<SubmitState> {
  SubmitCubit() : super(SubmitInitial());

  Future<void> submitForm(Future<bool> Function() submit) async {
    emit(SubmitLoading());
    try {
      final success = await submit();
      if (success) {
        emit(SubmitSuccess());
      } else {
        emit(SubmitFailure("فشل في تسليم الاستمارة. يرجى المحاولة مرة أخرى."));
      }
    } catch (e) {
      emit(SubmitFailure(e.toString()));
    }
  }
}
