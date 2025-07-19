part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthSuccess extends AuthState {
  final Map<String, String> data;

  AuthSuccess({this.data = const {}});
}

final class AuthLoading extends AuthState {}

final class AuthError extends AuthState {

}
