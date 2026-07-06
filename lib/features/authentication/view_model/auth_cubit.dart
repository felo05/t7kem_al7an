import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../repository/i_authentication_repository.dart';

part 'auth_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authenticationRepository) : super(LoginInitial());
  final IAuthenticationRepository _authenticationRepository;

  void login(String name, String password) async {
    emit(LoginLoadingState());
    final result = await _authenticationRepository.login(name, password);
    result.fold((error) => emit(LoginErrorState(message: error)),
        (user) => emit(LoginSuccessState(user: user)));
  }
}
