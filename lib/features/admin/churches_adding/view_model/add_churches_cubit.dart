import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/features/admin/repository/i_admin_repository.dart';

import '../model/add_church_form_data.dart';

part 'add_churches_state.dart';

class AddChurchesCubit extends Cubit<AddChurchesState> {
  AddChurchesCubit(this._repository) : super(AddChurchesInitial());
  final IAdminRepository _repository;

  Future<void> submit(AddChurchFormData data) async {
    emit(AddChurchesLoading());
    try {
      _repository.addChurch(data);
      emit(AddChurchesSuccess());
    } catch (e) {
      emit(AddChurchesError(e.toString()));
    }
  }
}
