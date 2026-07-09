import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../authentication/model/user_model.dart';
import '../../../repository/i_admin_repository.dart';


part 'get_judges_state.dart';

class GetJudgesCubit extends Cubit<GetJudgesState> {
  GetJudgesCubit(this._repository) : super(GetJudgesLoading());

  final IAdminRepository _repository;
  StreamSubscription? _sub;

  void start() {
    _sub = _repository.watchJudges().listen(
          (snapshot) {
        final List<UserModel> judges = snapshot.docs
            .map((doc) => doc.data())
            .toList();
        emit(GetJudgesLoaded(judges));
      },
      onError: (e) => emit(GetJudgesError(e.toString())),
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}