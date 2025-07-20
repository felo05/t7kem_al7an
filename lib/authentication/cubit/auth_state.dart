part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthSuccess extends AuthState {
  final List<MapEntry<String, String>>? data;
  final bool isAadmin;

  AuthSuccess({this.isAadmin=false,  this.data });
}

final class AuthLoading extends AuthState {}

final class AuthError extends AuthState {
  final String? message;
  AuthError({this.message});
}
