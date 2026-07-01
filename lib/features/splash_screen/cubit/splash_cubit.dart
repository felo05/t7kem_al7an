import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../core/notification/notification_service.dart';
import '../../../core/services/storage_service/storage_service.dart';
import '../../../main.dart';
import '../../authentication/user.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  void checkAuth() async {
    emit(SplashLoading());

    await StorageService().init();

    final NotificationService notificationService = NotificationService();
    await notificationService.initialize();

    await FirebaseMessaging.instance.requestPermission();

    final String? token = await FirebaseMessaging.instance.getToken();

    await FirebaseMessaging.instance.subscribeToTopic('all');
    print('🔑 FCM Token: $token');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final imageUrl =
            message.data['imageUrl'] ?? message.notification!.android?.imageUrl;

        notificationService.showNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          imageUrl: imageUrl,
        );
      }
    });
    try {
      final user = await StorageService.instance.getUser();
      if (user != null) {
        emit(LoggedIn(user: user));
      } else {
        emit(NotLoggedIn());
      }
    }
    catch (e) {
      emit(NotLoggedIn());
    }
  }
}
