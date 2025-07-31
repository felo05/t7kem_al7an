import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/authentication/auth_screen.dart';
import 'churches/cubit/churches_cubit.dart';
import 'firebase_options.dart';
import 'marks_forms/cubit/submit_cubit.dart';
import 'notification/notification_service.dart';

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
    print("+");
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("++");

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    print("+++");
    // final NotificationService notificationService = NotificationService();
    // await notificationService.initialize();
    //
    // // طلب إذن الإشعارات
    // await FirebaseMessaging.instance.requestPermission();

    // الاشتراك في topic عام
    //await FirebaseMessaging.instance.subscribeToTopic("all_users");
    print("++++");

    // طباعة الـ token (اختياري)
    // final token = await FirebaseMessaging.instance.getToken();
    // print("📲 FCM Token: $token");
    // رسائل الخلفية
    // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    //
    // // رسائل foreground
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   if (message.notification != null) {
    //     final imageUrl =
    //         message.data['imageUrl'] ?? message.notification!.android?.imageUrl;
    //
    //     notificationService.showNotification(
    //       title: message.notification!.title,
    //       body: message.notification!.body,
    //       imageUrl: imageUrl,
    //     );
    //   }
    // });
    print("+++++");
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SubmitCubit(),
        ),
        BlocProvider(
        create: (context) => ChurchesCubit()..getChurches(),
        )
      ],
      child: MaterialApp(
        builder: (context, child) =>
            Directionality(
              textDirection: TextDirection.rtl,
              child: child ?? const SizedBox.shrink(),
            ),
        debugShowCheckedModeBanner: false,
        home: const AuthScreen(),
      ),
    );
  }
}
