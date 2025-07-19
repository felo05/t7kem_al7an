import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:t7kem_al7an/authentication/auth_screen.dart';

import 'firebase_options.dart';
import 'screens/admin_screen.dart';

void main() async{

  // await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();
  // Temporarily disable Firebase for testing
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    
  );
   FirebaseFirestore.instance.settings = const Settings(
     persistenceEnabled: false, // disables offline cache
   );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthScreen(),
    );
  }
}
