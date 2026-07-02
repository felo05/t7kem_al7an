part of 'auth_cubit.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginSuccessState extends LoginState {
  final UserModel user;

  LoginSuccessState({required this.user});
}

final class LoginLoadingState extends LoginState {}

final class LoginErrorState extends LoginState {
  final String? message;
  LoginErrorState({this.message});
}
