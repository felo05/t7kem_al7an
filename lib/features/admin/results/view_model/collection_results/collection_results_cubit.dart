import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/features/admin/repository/i_admin_repository.dart';

import '../../model/church_average.dart';
import '../../model/church_average_calculator.dart';

part 'collection_results_state.dart';

class CollectionResultsCubit extends Cubit<CollectionResultsState> {
  CollectionResultsCubit(this._repository) : super(CollectionResultsInitial());
  final IAdminRepository _repository;
  StreamSubscription? _sub;

  void watch(String collectionName) {
    _sub = _repository.watchCollection(collectionName).listen(
          (docs) => emit(CollectionResultsSuccess(
              ChurchAverageCalculator.computeForRanking(docs))),
          onError: (_) => emit(CollectionResultsSuccess(
              const [])), // matches original silent catch -> []
        );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
