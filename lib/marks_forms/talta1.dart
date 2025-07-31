import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_gallery/saver_gallery.dart';
import '../constants/al7an.dart';
import '../widgets/marks_form_fields.dart';
import 'cubit/submit_cubit.dart';

class Talta1 extends StatefulWidget {
  const Talta1({super.key, required this.isTalta, required this.churchName});

  final bool isTalta;
  final String churchName;

  @override
  State<Talta1> createState() => _Talta1State();
}

class _Talta1State extends State<Talta1> {
  final GlobalKey _globalKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  late List<String> al7anList;
  late List<bool> bool1;
  late List<bool> bool2;
  late List<bool> bool3;
  late List<bool> bool4;
  late List<TextEditingController> controllers1;
  late List<TextEditingController> controllers2;
  late List<TextEditingController> controllers3;
  late List<TextEditingController> controllers4;
  late TextEditingController totalController;
  late TextEditingController copticReadingController;
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
    al7anList = widget.isTalta ? Al7an.talta1 : Al7an.khamsa1;
    bool1 = List.generate(3, (_) => false);
    bool2 = List.generate(3, (_) => false);
    bool3 = List.generate(3, (_) => false);
    bool4 = List.generate(3, (_) => false);
    slokController = TextEditingController(text: "10");
    controllers1 = List.generate(4, (_) => TextEditingController());
    controllers2 = List.generate(4, (_) => TextEditingController());
    controllers3 = List.generate(4, (_) => TextEditingController());
    controllers4 = List.generate(4, (_) => TextEditingController());
    totalController = TextEditingController();
    copticReadingController = TextEditingController();
    taksController = TextEditingController();
  }

  @override
  void dispose() {
    for (var c in [
      ...controllers1,
      ...controllers2,
      ...controllers3,
      ...controllers4,
      totalController,
      copticReadingController,
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
                ? "مرحلة تالتة ورابعة المستوى الاول"
                : "مرحلة خامسة وسادسة المستوى الاول",
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
                  Text(widget.churchName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w500,color: Colors.indigo)),
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
                  MarksFormFields.taks(taksController,4),
                  const SizedBox(height: 10),
                  MarksFormFields.copticReading(copticReadingController),
                  const SizedBox(height: 10),
                  MarksFormFields.total(totalController),
                  const SizedBox(height: 10),
                  MarksFormFields.slok(TextEditingController(text: "10")),
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
                      return MarksFormFields.submitButton(onPressed: () async {
                        context.read<SubmitCubit>().talta1(
                            widget.churchName,
                            al7anList,
                            controllers1,
                            controllers2,
                            controllers3,
                            controllers4,
                            totalController,
                            copticReadingController,
                            taksController,
                            slokController,
                            widget.isTalta,
                            bool1,
                            bool2,
                            bool3,
                            bool4,
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
