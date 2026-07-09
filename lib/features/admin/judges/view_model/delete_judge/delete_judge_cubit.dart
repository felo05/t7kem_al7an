import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/i_admin_repository.dart';

part 'delete_judge_state.dart';

class DeleteJudgeCubit extends Cubit<DeleteJudgeState> {
  DeleteJudgeCubit(this._repository) : super(DeleteJudgeInitial());

  final IAdminRepository _repository;

  Future<void> deleteJudge(String docId) async {
    emit(DeleteJudgeLoading());
    final error = await _repository.deleteJudge(docId);
    if (error == null) {
      emit(DeleteJudgeSuccess());
    } else {
      emit(DeleteJudgeError('حصلت مشكلة جرب تاني'));
    }
  }
}