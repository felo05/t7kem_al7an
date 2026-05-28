import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:t7kem_al7an/core/widgets/marks_form_fields.dart';
import 'package:t7kem_al7an/core/services/storage_service.dart';
import '../../authentication/user.dart';
import 'base_marks_form.dart';
import 'cubit/submit_cubit.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.form, required this.user});

  final BaseMarksFormModel form;
  final User user;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  @override
  void dispose() {
    widget.form.dispose();
    super.dispose();
  }

  Future<String?> _captureAndSaveFormImage() async {
    if (!mounted) {
      return null;
    }

    final overlay = Overlay.of(context);
    if (overlay == null) {
      return null;
    }

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
                                      fontSize: 22, fontWeight: FontWeight.w500)),
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
      final composed = await recorder
          .endRecording()
          .toImage(image.width, image.height);

      final byteData = await composed.toByteData(format: ui.ImageByteFormat.png);

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
          '${widget.form.churchName}_${DateTime.now().millisecondsSinceEpoch}.png';
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
        title: Text(widget.form.levelInArabic,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                widget.form.view(),
                const SizedBox(height: 20),
                BlocProvider(
                  create: (context) => SubmitCubit(),
                  child: BlocConsumer<SubmitCubit, SubmitState>(
                    listener: (context, state) {
                      if (state is SubmitSuccess) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("تم تسليم الاستمارة بنجاح!"),
                          backgroundColor: Colors.green,
                        ));
                      } else if (state is SubmitFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(state.error),
                          backgroundColor: Colors.red,
                        ));
                      }
                    },
                    builder: (context, state) {
                      if (state is SubmitLoading) {
                        return const CircularProgressIndicator();
                      }
                      return MarksFormFields.submitButton(
                        onPressed: () async {
                          _captureAndSaveFormImage();
                          if (widget.form.validate()) {
                            await context.read<SubmitCubit>().submitForm(
                              () => widget.form.submit(widget.user.name));
                          }
                        },
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
