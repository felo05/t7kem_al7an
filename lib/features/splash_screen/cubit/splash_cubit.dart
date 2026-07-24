import 'dart:async';
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

    // Fire-and-forget: push setup must never block or delay login resolution,
    // especially offline.
    _setupPushNotifications();

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

  Future<void> _setupPushNotifications() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();

      await FirebaseMessaging.instance
          .requestPermission()
          .timeout(const Duration(seconds: 5), onTimeout: () => throw TimeoutException('requestPermission timed out'));

      try {
        await FirebaseMessaging.instance
            .getToken()
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('FCM getToken failed: $e');
      }

      try {
        await FirebaseMessaging.instance
            .subscribeToTopic('all_users')
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('FCM subscribeToTopic failed: $e');
        // Non-fatal — will succeed on a future app open once network returns.
      }

      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.data.isNotEmpty) {
          notificationService.showNotification(
            title: message.data['title'],
            body: message.data['body'],
            imageUrl: message.data['imageUrl'],
          );
        }
      });
    } catch (e) {
      debugPrint('Push notification setup failed: $e');
    }
  }
}
