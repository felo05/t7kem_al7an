import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/notification_service/notification_service.dart';
import '../../../core/services/storage_service/storage_service.dart';
import '../../../main.dart';
import '../../authentication/model/user_model.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());
  Future<bool> checkAndRequestPermissions({required bool skipIfExists}) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return false; // Only Android and iOS platforms are supported
    }

    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;

      if (skipIfExists) {
        // Read permission is required to check if the file already exists
        return sdkInt >= 33
            ? await Permission.photos.request().isGranted
            : await Permission.storage.request().isGranted;
      } else {
        // No read permission required for Android SDK 29 and above
        return sdkInt >= 29
            ? true
            : await Permission.storage.request().isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS permission for saving images to the gallery
      return skipIfExists
          ? await Permission.photos.request().isGranted
          : await Permission.photosAddOnly.request().isGranted;
    }

    return false; // Unsupported platforms
  }

  void checkAuth() async {
    emit(SplashLoading());

    await StorageService().init();

    final NotificationService notificationService = NotificationService();
    await notificationService.initialize();

    await FirebaseMessaging.instance.requestPermission();

    await FirebaseMessaging.instance.getToken();

    await FirebaseMessaging.instance.subscribeToTopic('all_users');
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
    } catch (e) {
      emit(NotLoggedIn());
    }
  }
}
