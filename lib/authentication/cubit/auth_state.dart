part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthSuccess extends AuthState {
  final bool isAadmin;

  AuthSuccess({required this.isAadmin });
}

final class AuthLoading extends AuthState {}

final class AuthError extends AuthState {
  final String? message;
  AuthError({this.message});
}
