part of 'splash_cubit.dart';

@immutable
sealed class SplashState {}

final class SplashInitial extends SplashState {}

final class SplashLoading extends SplashState {}

final class LoggedIn extends SplashState {
  final UserModel user;
  LoggedIn({required this.user});
}

final class NotLoggedIn extends SplashState {}