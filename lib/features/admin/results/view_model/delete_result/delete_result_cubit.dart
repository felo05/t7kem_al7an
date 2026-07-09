import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/i_admin_repository.dart';

part 'delete_result_state.dart';

class DeleteResultCubit extends Cubit<DeleteResultState> {
  DeleteResultCubit(this._repository) : super(DeleteResultInitial());

  final IAdminRepository _repository;

  Future<void> delete(String collectionName, String documentId) async {
    emit(DeleteResultLoading());
    try {
      await _repository.deleteResult(collectionName, documentId);
      emit(DeleteResultSuccess());
    } catch (e) {
      emit(DeleteResultError(e.toString()));
    }
  }
}
