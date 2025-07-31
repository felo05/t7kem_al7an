import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_gallery/saver_gallery.dart';

import '../constants/al7an.dart';
import '../widgets/marks_form_fields.dart';
import 'cubit/submit_cubit.dart';

class Kg2 extends StatefulWidget {
  const Kg2({super.key, required this.isKg, required this.churchName});

  final bool isKg;
  final String churchName;

  @override
  State<Kg2> createState() => _Kg2State();
}

class _Kg2State extends State<Kg2> {
  final GlobalKey _globalKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

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
  Widget build(BuildContext context) {
    List<String> al7anList = widget.isKg ? Al7an.kg2 : Al7an.ola2;
    List<TextEditingController> controllers1 =
    List.generate(3, (index) => TextEditingController());
    List<TextEditingController> controllers2 =
    List.generate(3, (index) => TextEditingController());
    List<TextEditingController> controllers3 =
    List.generate(3, (index) => TextEditingController());
    List<TextEditingController> controllers4 =
    List.generate(3, (index) => TextEditingController());
    List<TextEditingController> controllers5 =
    List.generate(3, (index) => TextEditingController());
    List<TextEditingController> controllers6 =
    List.generate(3, (index) => TextEditingController());
    TextEditingController totalController = TextEditingController();
    TextEditingController slokController = TextEditingController(text: "10");

    return WillPopScope(
      onWillPop: () async {
        return await MarksFormFields.showExitConfirmationDialog(context);
      },
      child: Scaffold(
          appBar: AppBar(
              title: Text(widget.isKg
                  ? "مرحلة حضانة المستوى الثانى"
                  : "مرحلة اولى وتانية المستوى الثانى"),
              centerTitle: true),
          body: SingleChildScrollView(
              controller: _scrollController,
              child: RepaintBoundary(
                key: _globalKey,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    Text(widget.churchName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500,color: Colors.indigo)),
                    const SizedBox(height: 10),
                    MarksFormFields.kgForm(al7anList[0], controllers1),
                    const SizedBox(height: 10),
                    MarksFormFields.kgForm(al7anList[1], controllers2),
                    const SizedBox(height: 10),
                    MarksFormFields.kgForm(al7anList[2], controllers3),
                    const SizedBox(height: 10),
                    MarksFormFields.kgForm(al7anList[3], controllers4),
                    const SizedBox(height: 10),
                    MarksFormFields.kgForm(al7anList[4], controllers5),
                    const SizedBox(height: 10),
                    MarksFormFields.kgForm(al7anList[5], controllers6),
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
                          context.read<SubmitCubit>().kg2(
                              al7anList,
                              controllers1,
                              controllers2,
                              controllers3,
                              controllers4,
                              controllers5,
                              controllers6,
                              totalController,
                              slokController,
                              widget.isKg,
                              widget.churchName,
                              _captureAndSave
                          );
                        });
                      },
                    )
                  ]),
                ),
              ))),
    );
  }
}
