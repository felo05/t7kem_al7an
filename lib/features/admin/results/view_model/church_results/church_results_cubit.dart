import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/i_admin_repository.dart';
import '../../model/church_result_doc.dart';

part 'church_results_state.dart';

class ChurchResultsCubit extends Cubit<ChurchResultsState> {
  ChurchResultsCubit(this._repository) : super(ChurchResultsInitial());

  final IAdminRepository _repository;
  StreamSubscription? _sub;

  void watch(String collectionName, String churchName) {
    _sub = _repository.watchChurchResults(collectionName, churchName).listen(
          (docs) {
        final sorted = [...docs]..sort((a, b) => b.percent.compareTo(a.percent));
        emit(ChurchResultsSuccess(sorted));
      },
      onError: (_) => emit(ChurchResultsSuccess(const [])), // matches original silent catch -> []
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
