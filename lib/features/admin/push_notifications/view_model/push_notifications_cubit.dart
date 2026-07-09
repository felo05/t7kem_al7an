import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/features/admin/repository/i_admin_repository.dart';

part 'push_notifications_state.dart';

class PushNotificationsCubit extends Cubit<PushNotificationsState> {
  PushNotificationsCubit(this._adminRepository)
      : super(PushNotificationsInitial());

  final IAdminRepository _adminRepository;

  Future<void> sendPushNotification({
    required String title,
    required String body,
  }) async {
    emit(PushNotificationsLoading());
    final result = await _adminRepository.sendPushNotification(
      title: title,
      body: body,
    );
    if (result != null) {
      emit(PushNotificationsSuccess());
    } else {
      emit(
          PushNotificationsError(message: 'Failed to send push notification.'));
    }
  }
}
