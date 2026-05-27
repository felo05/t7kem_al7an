import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:t7kem_al7an/features/splash_screen/splash_screen.dart';
import 'core/notification/notification_service.dart';
import 'core/services/storage_service.dart';
import 'firebase_options.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationService().showNotification(
      title: message.data["title"], body: message.data["body"]);
  print('📥 Background message received: ${message.notification?.title}');
}

void main() async {
  try{
    WidgetsFlutterBinding.ensureInitialized();

    await StorageService().init();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    final NotificationService notificationService = NotificationService();
    await notificationService.initialize();

    await FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.instance.getToken();
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
    runApp(const MyApp());
  }catch(e) {
    print("========================================================");
    print("Error initializing Firebase: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) =>
          Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
