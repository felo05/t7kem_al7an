part of 'push_notifications_cubit.dart';

@immutable
sealed class PushNotificationsState {}

final class PushNotificationsInitial extends PushNotificationsState {}

final class PushNotificationsSuccess extends PushNotificationsState {}

final class PushNotificationsLoading extends PushNotificationsState {}

final class PushNotificationsError extends PushNotificationsState {
  final String message;

  PushNotificationsError({required this.message});
}
