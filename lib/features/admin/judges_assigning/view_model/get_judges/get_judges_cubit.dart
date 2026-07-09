import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/i_admin_repository.dart';

part 'get_judges_state.dart';

class GetJudgesCubit extends Cubit<GetJudgesState> {
  GetJudgesCubit(this._repository) : super(GetJudgesInitial());
  final IAdminRepository _repository;

  Future<void> fetch() async {
    emit(GetJudgesLoading());
    try {
      final names = await _repository.fetchJudgeNames();
      emit(GetJudgesSuccess(names));
    } catch (e) {
      emit(GetJudgesError(e.toString()));
    }
  }
}
