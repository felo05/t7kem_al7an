import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_gallery/saver_gallery.dart';
import '../constants/al7an.dart';
import '../widgets/marks_form_fields.dart';
import 'cubit/submit_cubit.dart';

class Talta2 extends StatefulWidget {
  const Talta2({super.key, required this.isTalta, required this.churchName});

  final bool isTalta;
  final String churchName;

  @override
  State<Talta2> createState() => _Talta2State();
}

class _Talta2State extends State<Talta2> {
  final GlobalKey _globalKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  late List<String> al7anList;
  late List<bool> bool1;
  late List<bool> bool2;
  late List<bool> bool3;
  late List<bool> bool4;
  late List<bool> bool5;
  late List<bool> bool6;

  late List<TextEditingController> controllers1;
  late List<TextEditingController> controllers2;
  late List<TextEditingController> controllers3;
  late List<TextEditingController> controllers4;
  late List<TextEditingController> controllers5;
  late List<TextEditingController> controllers6;

  late TextEditingController totalController;
  late TextEditingController taksController;
  late TextEditingController slokController;
  Future<void> _captureAndSave() async {
    try {
      WidgetsBinding.instance.endOfFrame;
      RenderRepaintBoundary boundary =
      _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Ensure the boundary is fully painted


      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // Use PNG format but save with JPG extension
        // The system will handle the conversion
        await SaverGallery.saveImage(
          pngBytes,
          fileName: "form_${DateTime.now().millisecondsSinceEpoch}.jpg",
          skipIfExists: true,
        );
        print("Image saved successfully");
      }
    } catch (e) {
      print("Error capturing screenshot: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    al7anList = widget.isTalta ? Al7an.talta2 : Al7an.khamsa2;

    bool1 = List.generate(3, (_) => false);
    bool2 = List.generate(3, (_) => false);
    bool3 = List.generate(3, (_) => false);
    bool4 = List.generate(3, (_) => false);
    bool5 = List.generate(3, (_) => false);
    bool6 = List.generate(3, (_) => false);
    slokController= TextEditingController(text: "10");
    controllers1 = List.generate(4, (_) => TextEditingController());
    controllers2 = List.generate(4, (_) => TextEditingController());
    controllers3 = List.generate(4, (_) => TextEditingController());
    controllers4 = List.generate(4, (_) => TextEditingController());
    controllers5 = List.generate(4, (_) => TextEditingController());
    controllers6 = List.generate(4, (_) => TextEditingController());

    totalController = TextEditingController();
    taksController = TextEditingController();
  }

  @override
  void dispose() {
    for (var c in [
      ...controllers1,
      ...controllers2,
      ...controllers3,
      ...controllers4,
      ...controllers5,
      ...controllers6,
      totalController,
      taksController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await MarksFormFields.showExitConfirmationDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isTalta
                ? "مرحلة تالتة ورابعة المستوى التانى"
                : "مرحلة خامسة وسادسة المستوى التانى",
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: RepaintBoundary(
            key: _globalKey,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    widget.churchName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500,color: Colors.indigo),
                  ),
                  const SizedBox(height: 10),
                  MarksFormFields.taltaForm(al7anList[0], controllers1, bool1,
                          (index, value) {
                        setState(() {
                          bool1[index] = value ?? false;
                        });
                      }),
                  const SizedBox(height: 10),
                  MarksFormFields.taltaForm(al7anList[1], controllers2, bool2,
                          (index, value) {
                        setState(() {
                          bool2[index] = value ?? false;
                        });
                      }),
                  const SizedBox(height: 10),
                  MarksFormFields.taltaForm(al7anList[2], controllers3, bool3,
                          (index, value) {
                        setState(() {
                          bool3[index] = value ?? false;
                        });
                      }),
                  const SizedBox(height: 10),
                  MarksFormFields.taltaForm(al7anList[3], controllers4, bool4,
                          (index, value) {
                        setState(() {
                          bool4[index] = value ?? false;
                        });
                      }),
                  const SizedBox(height: 10),
                  MarksFormFields.taltaForm(al7anList[4], controllers5, bool5,
                          (index, value) {
                        setState(() {
                          bool5[index] = value ?? false;
                        });
                      }),
                  const SizedBox(height: 10),
                  MarksFormFields.taltaForm(al7anList[5], controllers6, bool6,
                          (index, value) {
                        setState(() {
                          bool6[index] = value ?? false;
                        });
                      }),
                  const SizedBox(height: 10),
                  MarksFormFields.taks(taksController,6),
                  const SizedBox(height: 10),
                  MarksFormFields.total(totalController),
                  const SizedBox(height: 10),
                  MarksFormFields.slok(slokController),
                  const SizedBox(height: 10),
                  BlocConsumer<SubmitCubit, SubmitState>(
                    listener: (context, state) {
                      if(state is SubmitSuccess) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("تم حفظ البيانات بنجاح"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (state is SubmitFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.error),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is SubmitLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.indigo,),
                        );
                      }
                      return MarksFormFields.submitButton(onPressed: () {
                        context.read<SubmitCubit>().talta2(
                            widget.churchName,
                            al7anList,
                            controllers1,
                            controllers2,
                            controllers3,
                            controllers4,
                            controllers5,
                            controllers6,
                            taksController,
                            totalController,
                            slokController,
                            widget.isTalta,
                            bool1,
                            bool2,
                            bool3,
                            bool4,
                            bool5,
                            bool6,
                            _captureAndSave
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
