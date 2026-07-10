import 'dart:io';

class FormImageModel {
  FormImageModel({required this.path, required this.fileName});

  final String path;
  final String fileName;

  String get churchName => fileName.split('_').first;

  factory FormImageModel.fromPath(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    return FormImageModel(path: path, fileName: fileName);
  }

  /// Matches ChurchesScreen's original lookup pattern: '${churchName}_${userName}'
  bool matches({String? churchName, String? userName}) {
    if (churchName == null && userName == null) return true;
    final pattern = '${churchName ?? ''}_${userName ?? ''}';
    return path.contains(pattern);
  }
}
