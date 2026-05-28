import 'package:hive_flutter/hive_flutter.dart';
import 'package:t7kem_al7an/features/authentication/user.dart';

class StorageService {
  static const String _boxName = 'user_cache';
  static const String _userKey = 'user';
  static const String _formImagePathsKey = 'form_image_paths';
  static const String _formImagePathsValueKey = 'paths';
  User? user;

  StorageService._();

  static final StorageService instance = StorageService._();

  factory StorageService() => instance;

  Box<Map>? _box;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      await Hive.initFlutter();
      _isInitialized = true;
    }

    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<Map>(_boxName);
      return;
    }

    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<void> saveUser(User user) async {
    final box = await _getBox();
    this.user = user;
    await box.put(_userKey, user.toJson());
  }

  Future<User?> getUser() async {
    final box = await _getBox();
    final data = box.get(_userKey);

    if (data == null) {
      return null;
    }
    user = User.fromJson(Map<String, dynamic>.from(data));

    return user;
  }

  Future<void> deleteUser() async {
    final box = await _getBox();
    user = null;
    await box.delete(_userKey);
  }


  Future<void> addFormImagePath(String path) async {
    final box = await _getBox();
    final data = box.get(_formImagePathsKey);
    final List<String> paths = data == null
        ? <String>[]
        : List<String>.from((data)[_formImagePathsValueKey] as List? ?? const []);
    paths.add(path);
    await box.put(_formImagePathsKey, {_formImagePathsValueKey: paths});
  }

  Future<List<String>> getFormImagePaths() async {
    final box = await _getBox();
    final data = box.get(_formImagePathsKey);
    if (data == null) {
      return const [];
    }
    return List<String>.from((data)[_formImagePathsValueKey] as List? ?? const []);
  }

  Future<Box<Map>> _getBox() async {
    if (_box != null) {
      return _box!;
    }

    await init();
    return _box!;
  }
}
