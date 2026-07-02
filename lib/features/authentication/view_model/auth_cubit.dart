import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:t7kem_al7an/features/authentication/repository/authentication_repository.dart';
import '../model/user_model.dart';

part 'auth_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  final AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();

  void login(String name, String password) async {
    emit(LoginLoadingState());
    final result = await _authenticationRepository.login(name, password);
    result.fold((error) => emit(LoginErrorState(message: error)),
        (user) => emit(LoginSuccessState(user: user)));
  }
}
