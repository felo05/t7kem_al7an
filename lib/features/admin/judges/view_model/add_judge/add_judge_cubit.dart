import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/features/authentication/model/user_model.dart';

import '../../../repository/i_admin_repository.dart';

part 'add_judge_state.dart';

class AddJudgeCubit extends Cubit<AddJudgeState> {
  AddJudgeCubit(this._repository) : super(AddJudgeInitial());

  final IAdminRepository _repository;

  Future<void> submit(UserModel user) async {
    emit(AddJudgeLoading());

    final error = user.docId == null
        ? await _repository.addJudge(user)
        : await _repository.editJudge(user);

    if (error == null) {
      emit(AddJudgeSuccess(isEditing: user.docId != null));
    } else {
      emit(AddJudgeError('حصلت مشكلة جرب تاني'));
    }
  }
}
