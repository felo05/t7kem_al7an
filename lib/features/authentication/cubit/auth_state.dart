part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthSuccess extends AuthState {
  final User user;

  AuthSuccess({required this.user });
}

final class AuthLoading extends AuthState {}

final class AuthError extends AuthState {
  final String? message;
  AuthError({this.message});
}
