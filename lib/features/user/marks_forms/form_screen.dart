import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:t7kem_al7an/core/services/storage_service/storage_service.dart';
import '../../authentication/model/user_model.dart';
import 'base_marks_form.dart';
import 'cubit/submit_cubit.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({
    super.key,
    required this.form,
    this.user,
    this.judgeName,
    this.captureOnSubmit = true,
    this.editCollectionName,
    this.editDocumentId,
  });

  final BaseMarksFormModel form;
  final UserModel? user;
  final String? judgeName;
  final bool captureOnSubmit;
  final String? editCollectionName;
  final String? editDocumentId;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  Future<String?> _captureAndSaveFormImage() async {
    if (!mounted) {
      return null;
    }

    final overlay = Overlay.of(context);

    final captureKey = GlobalKey();
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    OverlayEntry? entry;

    try {
      entry = OverlayEntry(
        builder: (context) {
          final media = MediaQuery.of(context);
          return IgnorePointer(
            child: Opacity(
              opacity: 0.01,
              child: Material(
                color: backgroundColor,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: media.size.width,
                    child: OverflowBox(
                      alignment: Alignment.topCenter,
                      maxHeight: double.infinity,
                      minHeight: 0,
                      child: RepaintBoundary(
                        key: captureKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppBar(
                              title: Text(widget.form.levelInArabic,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500)),
                              centerTitle: true,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: widget.form.view(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

      overlay.insert(entry);
      await Future.delayed(const Duration(milliseconds: 100));
      await WidgetsBinding.instance.endOfFrame;

      final boundary = captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        return null;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..color = backgroundColor;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        paint,
      );
      canvas.drawImage(image, Offset.zero, Paint());
      final composed =
          await recorder.endRecording().toImage(image.width, image.height);

      final byteData =
          await composed.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return null;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final dir = await getApplicationDocumentsDirectory();
      final formsDir = Directory('${dir.path}${Platform.pathSeparator}forms');
      if (!await formsDir.exists()) {
        await formsDir.create(recursive: true);
      }

      final fileName =
          '${widget.form.churchName}_${widget.user?.name}_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${formsDir.path}${Platform.pathSeparator}$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes, flush: true);

      await _ensureGalleryPermission();
      await SaverGallery.saveImage(
        pngBytes,
        fileName: fileName,
        skipIfExists: true,
      );

      await StorageService.instance.addFormImagePath(filePath);
      return filePath;
    } catch (e) {
      return null;
    } finally {
      entry?.remove();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.form.levelInArabic,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange.shade700,
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
            colors: [
              Colors.orange.shade700,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: widget.form.view(),
                ),
                const SizedBox(height: 20),
                BlocProvider(
                  create: (context) => SubmitCubit(),
                  child: BlocConsumer<SubmitCubit, SubmitState>(
                    listener: (context, state) {
                      if (state is SubmitSuccess) {
                        Navigator.pop(context, state.payload);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("تم تسليم الاستمارة بنجاح!"),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (state is SubmitFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.error),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is SubmitLoading) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const SizedBox(
                            height: 50,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        );
                      }
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () async {
                            if (widget.captureOnSubmit) {
                              await _captureAndSaveFormImage();
                            }
                            if (widget.form.validate()) {
                              final judgeName =
                                  widget.judgeName ?? widget.user?.name;
                              if (judgeName == null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('برجاء تحديد اسم المحكم'),
                                  backgroundColor: Colors.red,
                                ));
                                return;
                              }
                              if (widget.editCollectionName != null &&
                                  widget.editDocumentId != null) {
                                final payload =
                                    widget.form.buildPayload(judgeName);
                                await context.read<SubmitCubit>().submitForm(
                                      () => widget.form.editSubmit(
                                          collectionName:
                                              widget.editCollectionName!,
                                          documentId: widget.editDocumentId!,
                                          judgeName: judgeName),
                                      payload: payload,
                                    );
                                return;
                              }
                              await context.read<SubmitCubit>().submitForm(
                                  () => widget.form.submit(judgeName));
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'تسليم الاستمارة',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
