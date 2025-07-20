import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:saver_gallery/saver_gallery.dart';
import '../authentication/cubit/auth_cubit.dart';
import '../constants/al7an.dart';
import '../constants/firebase.dart';
import '../widgets/marks_form_fields.dart';

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

  Future<void> _captureAndSave() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);

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
  void initState() {
    super.initState();
    al7anList = widget.isTalta ? Al7an.talta2 : Al7an.khamsa2;

    bool1 = List.generate(3, (_) => false);
    bool2 = List.generate(3, (_) => false);
    bool3 = List.generate(3, (_) => false);
    bool4 = List.generate(3, (_) => false);
    bool5 = List.generate(3, (_) => false);
    bool6 = List.generate(3, (_) => false);

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
    return Scaffold(
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
                      fontSize: 20, fontWeight: FontWeight.w500),
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
                MarksFormFields.taks(taksController),
                const SizedBox(height: 10),
                MarksFormFields.total(totalController),
                const SizedBox(height: 10),
                MarksFormFields.submitButton(onPressed: () async {
                  await _captureAndSave();
                  Map<String, dynamic> estmara = {
                    "judge": AuthCubit.name,
                    "churchName": widget.churchName,
                    "kidsTotal": totalController.text,
                  };
                  estmara[al7anList[0]] = {
                    Al7an.tslem: controllers1[0].text,
                    Al7an.tempo: controllers1[1].text,
                    Al7an.ro7ania: controllers1[2].text,
                    Al7an.copticSpelling: controllers1[3].text,
                    Al7an.df: bool1[0],
                    Al7an.treanto: bool1[1],
                    Al7an.hzat: bool1[2]
                  };
                  estmara[al7anList[1]] = {
                    Al7an.tslem: controllers2[0].text,
                    Al7an.tempo: controllers2[1].text,
                    Al7an.ro7ania: controllers2[2].text,
                    Al7an.copticSpelling: controllers2[3].text,
                    Al7an.df: bool2[0],
                    Al7an.treanto: bool2[1],
                    Al7an.hzat: bool2[2]
                  };
                  estmara[al7anList[2]] = {
                    Al7an.tslem: controllers3[0].text,
                    Al7an.tempo: controllers3[1].text,
                    Al7an.ro7ania: controllers3[2].text,
                    Al7an.copticSpelling: controllers3[3].text,
                    Al7an.df: bool3[0],
                    Al7an.treanto: bool3[1],
                    Al7an.hzat: bool3[2]
                  };
                  estmara[al7anList[3]] = {
                    Al7an.tslem: controllers4[0].text,
                    Al7an.tempo: controllers4[1].text,
                    Al7an.ro7ania: controllers4[2].text,
                    Al7an.copticSpelling: controllers4[3].text,
                    Al7an.df: bool4[0],
                    Al7an.treanto: bool4[1],
                    Al7an.hzat: bool4[2]
                  };
                  estmara[al7anList[4]] = {
                    Al7an.tslem: controllers5[0].text,
                    Al7an.tempo: controllers5[1].text,
                    Al7an.ro7ania: controllers5[2].text,
                    Al7an.copticSpelling: controllers5[3].text,
                    Al7an.df: bool5[0],
                    Al7an.treanto: bool5[1],
                    Al7an.hzat: bool5[2]
                  };
                  estmara[al7anList[5]] = {
                    Al7an.tslem: controllers6[0].text,
                    Al7an.tempo: controllers6[1].text,
                    Al7an.ro7ania: controllers6[2].text,
                    Al7an.copticSpelling: controllers6[3].text,
                    Al7an.df: bool6[0],
                    Al7an.treanto: bool6[1],
                    Al7an.hzat: bool6[2]
                  };

                  double sum = 10;
                  for (var controller in controllers1) {
                    sum += int.parse(controller.text);
                  }
                  for (var controller in controllers2) {
                    sum += int.parse(controller.text);
                  }
                  for (var controller in controllers3) {
                    sum += int.parse(controller.text);
                  }
                  for (var controller in controllers4) {
                    sum += int.parse(controller.text);
                  }
                  for (var controller in controllers5) {
                    sum += int.parse(controller.text);
                  }
                  for (var controller in controllers6) {
                    sum += int.parse(controller.text);
                  }
                  sum += bool1[0] ? .5 : 0;
                  sum += bool1[1] ? .5 : 0;
                  sum += !bool1[2] ? 1 : 0;
                  sum += bool2[0] ? .5 : 0;
                  sum += bool2[1] ? .5 : 0;
                  sum += !bool2[2] ? 1 : 0;
                  sum += bool3[0] ? .5 : 0;
                  sum += bool3[1] ? .5 : 0;
                  sum += !bool3[2] ? 1 : 0;
                  sum += bool4[0] ? .5 : 0;
                  sum += bool4[1] ? .5 : 0;
                  sum += !bool4[2] ? 1 : 0;
                  sum += bool5[0] ? .5 : 0;
                  sum += bool5[1] ? .5 : 0;
                  sum += !bool5[2] ? 1 : 0;
                  sum += bool6[0] ? .5 : 0;
                  sum += bool6[1] ? .5 : 0;
                  sum += !bool6[2] ? 1 : 0;
                  sum += int.parse(taksController.text);
                  estmara["taks"] = int.parse(taksController.text);
                  estmara["total"] = sum;

                  estmara["percent"] = sum / 328;
                  final FirebaseFirestore fireStore =
                      FirebaseFirestore.instance;
                  await fireStore
                      .collection(
                          "${widget.isTalta ? Firebase.talta2 : Firebase.khamsa2}result")
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
    );
  }
}
