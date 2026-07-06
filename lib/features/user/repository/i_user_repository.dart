import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract interface class IUserRepository {
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchLevelDay({
    required String level,
    required String dayName,
  });

  Future<List<String>> getFormImagePaths();

  Future<String?> saveCapturedForm({
    required Uint8List pngBytes,
    required String churchName,
    required String userName,
  });
}