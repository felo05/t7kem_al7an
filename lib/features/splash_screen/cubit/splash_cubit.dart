import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../../authentication/user.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  void checkAuth() async {
    emit(SplashLoading());

    try {
      final user = await StorageService.instance.getUser();
      if (user != null) {
        emit(LoggedIn(user: user));
      } else {
        emit(NotLoggedIn());
      }
    }
    catch (e) {
      emit(NotLoggedIn());
    }
  }
}
