import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:t7kem_al7an/features/user/repository/i_user_repository.dart';
import '../../../../../core/di/service_locator.dart';
import '../../model/form_image_model.dart';
import '../../viewmodel/forms_images_cubit.dart';

class FormsImagesScreen extends StatelessWidget {
  const FormsImagesScreen({super.key, this.churchName, this.userName});

  final String? churchName;
  final String? userName;

  void _openPreview(BuildContext context, FormImageModel image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(image.churchName),
            centerTitle: true,
            backgroundColor: Colors.purple.shade700,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  await SharePlus.instance.share(
                    ShareParams(
                      files: [XFile(image.path)],
                      subject: image.churchName,
                    ),
                  );
                },
                tooltip: 'Share image',
              ),
            ],
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text(
                    'Image not found.',
                    style: TextStyle(color: Colors.white),
                  ),
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
    return BlocProvider(
      create: (_) => FormsImagesCubit(sl<IUserRepository>())
        ..load(churchName: churchName, userName: userName),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الاستمارات المحفوظة',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.purple.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.purple.shade700, Colors.purple.shade50],
            ),
          ),
          child: BlocBuilder<FormsImagesCubit, FormsImagesState>(
            builder: (context, state) {
              if (state is FormsImagesLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (state is FormsImagesError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Failed to load images.',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context
                            .read<FormsImagesCubit>()
                            .load(churchName: churchName, userName: userName),
                        child: const Text('حاول تاني'),
                      ),
                    ],
                  ),
                );
              }

              final images = (state as FormsImagesSuccess).images;

              if (images.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لسا مفيش استمارات محفوظة',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final image = images[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => _openPreview(context, image),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: Image.file(
                                File(image.path),
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 200,
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                      child: Text('Image not found.')),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple.shade50, Colors.white],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                image.churchName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                image.fileName,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
