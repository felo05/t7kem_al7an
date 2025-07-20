import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:t7kem_al7an/authentication/cubit/auth_cubit.dart';
import 'package:t7kem_al7an/widgets/marks_form_fields.dart';
import '../constants/al7an.dart';
import '../constants/firebase.dart';

class Kg1 extends StatefulWidget {
  const Kg1({super.key, required this.isKg, required this.churchName});

  final bool isKg;
  final String churchName;

  @override
  State<Kg1> createState() => _Kg1State();
}

class _Kg1State extends State<Kg1> {
  final GlobalKey _globalKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  Future<void> _captureAndSave() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        await SaverGallery.saveImage(
          pngBytes,
          fileName: "form_${DateTime.now().millisecondsSinceEpoch}.png",
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
    List<String> al7anList = widget.isKg ? Al7an.kg1 : Al7an.ola1;
    List<TextEditingController> controllers1 = List.generate(
      3,
      (index) => TextEditingController(),
    );
    List<TextEditingController> controllers2 = List.generate(
      3,
      (index) => TextEditingController(),
    );
    List<TextEditingController> controllers3 = List.generate(
      3,
      (index) => TextEditingController(),
    );
    List<TextEditingController> controllers4 = List.generate(
      3,
      (index) => TextEditingController(),
    );
    TextEditingController totalController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isKg
            ? "مرحلة حضانة المستوى الاول"
            : "مرحلة اولى وتانية المستوى الاول"),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white, // Ensure white background
        child: SingleChildScrollView(
          controller: _scrollController,
          child: RepaintBoundary(
            key: _globalKey,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.white,
              child: Column(
                children: [
                  Text(
                    widget.churchName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  MarksFormFields.kgForm(al7anList[0], controllers1),
                  const SizedBox(height: 10),
                  MarksFormFields.kgForm(al7anList[1], controllers2),
                  const SizedBox(height: 10),
                  MarksFormFields.kgForm(al7anList[2], controllers3),
                  const SizedBox(height: 10),
                  MarksFormFields.kgForm(al7anList[3], controllers4),
                  const SizedBox(height: 10),
                  MarksFormFields.total(totalController),
                  const SizedBox(height: 10),
                  MarksFormFields.submitButton(onPressed: () async {
                    await _captureAndSave();

                    Map<String, dynamic> estmara = {
                      "churchName": widget.churchName,
                      "kidsTotal": totalController.text,
                      "judge": AuthCubit.name
                    };
                    double sum = 10;

                    estmara[al7anList[0]] = {
                      Al7an.tslem: controllers1[0].text,
                      Al7an.tempo: controllers1[1].text,
                      Al7an.ro7ania: controllers1[2].text,
                    };
                    estmara[al7anList[1]] = {
                      Al7an.tslem: controllers2[0].text,
                      Al7an.tempo: controllers2[1].text,
                      Al7an.ro7ania: controllers2[2].text,
                    };
                    estmara[al7anList[2]] = {
                      Al7an.tslem: controllers3[0].text,
                      Al7an.tempo: controllers3[1].text,
                      Al7an.ro7ania: controllers3[2].text,
                    };
                    estmara[al7anList[3]] = {
                      Al7an.tslem: controllers4[0].text,
                      Al7an.tempo: controllers4[1].text,
                      Al7an.ro7ania: controllers4[2].text,
                    };

                    for (var controller in [
                      ...controllers1,
                      ...controllers2,
                      ...controllers3,
                      ...controllers4
                    ]) {
                      sum += int.tryParse(controller.text) ?? 0;
                    }

                    estmara["total"] = sum;
                    estmara["percent"] = sum / 174;

                    final FirebaseFirestore fireStore =
                        FirebaseFirestore.instance;
                    await fireStore
                        .collection(
                            "${widget.isKg ? Firebase.kg1 : Firebase.ola1}result")
                        .add(estmara)
                        .then((val) {
                      Navigator.pop(context);
                    });
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
