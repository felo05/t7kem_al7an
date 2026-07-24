import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';

import '../../../core/services/storage_service/storage_service.dart';
import 'i_user_repository.dart';

class UserRepository implements IUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService.instance;

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchLevelDay({
    required String level,
    required String dayName,
  }) {
    return _firestore.collection(level).doc(dayName).snapshots();
  }

  @override
  Future<List<String>> getFormImagePaths() {
    return _storageService.getFormImagePaths();
  }

  @override
  Future<String?> saveCapturedForm({
    required Uint8List pngBytes,
    required String churchName,
    required String userName,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final formsDir = Directory('${dir.path}${Platform.pathSeparator}forms');
      if (!await formsDir.exists()) {
        await formsDir.create(recursive: true);
      }

      final fileName =
          '${churchName}_${userName}_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${formsDir.path}${Platform.pathSeparator}$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes, flush: true);

      debugPrint("File saved locally: $filePath");

      await _ensureGalleryPermission();

      try {
        await SaverGallery.saveImage(
          pngBytes,
          fileName: fileName,
          skipIfExists: true,
        );
        debugPrint("Gallery save successful");
      } catch (e) {
        debugPrint("Gallery save failed: $e");
      }

      await StorageService.instance.addFormImagePath(filePath);

      return filePath;
    } catch (e) {
      return null;
    }
  }

  Future<void> _ensureGalleryPermission() async {
    if (Platform.isIOS) {
      await Permission.photos.request();
      return;
    }
    if (Platform.isAndroid) {
      await Permission.photos.request();
      await Permission.storage.request();
    }
  }
}
