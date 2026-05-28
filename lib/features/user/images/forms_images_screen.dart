import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t7kem_al7an/core/services/storage_service.dart';

class FormsImagesScreen extends StatelessWidget {
  const FormsImagesScreen({super.key});

  void _openPreview(BuildContext context, String path, String fileName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(fileName.split('_').first),centerTitle: true),
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                File(path),
                errorBuilder: (_, __, ___) => const Text(
                  'Image not found.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الاستمارات المحفوظة'),centerTitle: true),
      body: FutureBuilder<List<String>>(
        future: StorageService.instance.getFormImagePaths(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load images.'));
          }

          final rawPaths = snapshot.data ?? const [];
          if (rawPaths.isEmpty) {
            return const Center(child: Text('No saved forms yet.'));
          }

          final paths = rawPaths.reversed.toList();

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: paths.length,
            separatorBuilder: (_, __) => const Column(
              children: [
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Divider(thickness: 1, color: Colors.grey)
                ),
                SizedBox(height: 8),
              ],
            ),
            itemBuilder: (context, index) {
              final path = paths[index];
              final fileName = path.split(Platform.pathSeparator).last;
              return Card(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => _openPreview(context, path, fileName),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Material(
                          color: Colors.transparent,
                          child: Image.file(
                            File(path),
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                            errorBuilder: (_, __, ___) => const SizedBox(
                              height: 140,
                              child: Center(child: Text('Image not found.')),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fileName.split('_').first,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}