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

class MohobenGroup extends StatefulWidget {
  const MohobenGroup(
      {super.key, required this.level, required this.churchName});
  final int level;
  final String churchName;
  @override
  State<MohobenGroup> createState() => _MohobenGroupState();
}

class _MohobenGroupState extends State<MohobenGroup> {
  final GlobalKey _globalKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  late List<TextEditingController> controllers1;
  late List<TextEditingController> controllers2;
  late List<TextEditingController> controllers3;
  final TextEditingController totalController = TextEditingController();
  late List<bool> bool1;
  late List<bool> bool2;
  late List<bool> bool3;
  late List<String> al7anList;

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
    controllers1 = List.generate(5, (_) => TextEditingController());
    controllers2 = List.generate(5, (_) => TextEditingController());
    controllers3 = List.generate(5, (_) => TextEditingController());
    bool1 = List.generate(2, (_) => false);
    bool2 = List.generate(2, (_) => false);
    bool3 = List.generate(2, (_) => false);
    al7anList = widget.level == 0
        ? Al7an.kg3
        : widget.level == 1
            ? Al7an.ola3
            : widget.level == 2
                ? Al7an.talta3
                : Al7an.khamsa3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.level == 0
              ? "موهوبين جماعى مرحلة حضانة"
              : widget.level == 1
                  ? "موهوبين جماعى مرحلة اولي وتانية"
                  : widget.level == 2
                      ? "موهوبين جماعى مرحلة تالتة ورابعة"
                      : "موهوبين جماعى مرحلة خامسة وسادسة",
        ),
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
                MarksFormFields.mohobenGroupForm(
                  al7anList[0],
                  controllers1,
                  bool1,
                  (index, value) {
                    setState(() {
                      bool1[index] = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 20),
                MarksFormFields.mohobenGroupForm(
                  al7anList[1],
                  controllers2,
                  bool2,
                  (index, value) {
                    setState(() {
                      bool2[index] = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 20),
                MarksFormFields.mohobenGroupForm(
                  al7anList[2],
                  controllers3,
                  bool3,
                  (index, value) {
                    setState(() {
                      bool3[index] = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: 10),
                MarksFormFields.total(totalController),
                const SizedBox(height: 10),
                MarksFormFields.submitButton(
                  onPressed: () async {
                    await _captureAndSave();
                    double factor = 1;
                    Map<String, dynamic> estmara = {
                      "churchName": widget.churchName,
                      "kidsTotal": totalController.text,
                      "judge": AuthCubit.name
                    };
                    estmara[al7anList[0]] = {
                      Al7an.tslem: controllers1[0].text,
                      Al7an.tempo: controllers1[1].text,
                      Al7an.tnas2: controllers1[2].text,
                      Al7an.copticReading: controllers1[3].text,
                      Al7an.ro7ania: controllers1[4].text,
                      Al7an.taks: bool1[0],
                      Al7an.df: bool1[1],
                    };
                    estmara[al7anList[1]] = {
                      Al7an.tslem: controllers2[0].text,
                      Al7an.tempo: controllers2[1].text,
                      Al7an.tnas2: controllers2[2].text,
                      Al7an.copticReading: controllers2[3].text,
                      Al7an.ro7ania: controllers2[4].text,
                      Al7an.taks: bool2[0],
                      Al7an.df: bool2[1],
                    };
                    estmara[al7anList[2]] = {
                      Al7an.tslem: controllers3[0].text,
                      Al7an.tempo: controllers3[1].text,
                      Al7an.tnas2: controllers3[2].text,
                      Al7an.copticReading: controllers3[3].text,
                      Al7an.ro7ania: controllers3[4].text,
                      Al7an.taks: bool3[0],
                      Al7an.df: bool3[1],
                    };
                    double sum = 0;
                    for (var controller in controllers3) {
                      sum += int.parse(controller.text);
                    }
                    sum += bool3[0] ? 1 : 0;
                    sum += bool3[1] ? 1 : 0;
                    factor = (sum >= 50 && sum <= 53)
                        ? 1.01
                        : (sum >= 54 && sum <= 56)
                            ? 1.02
                            : (sum >= 57 && sum <= 59)
                                ? 1.05
                                : (sum >= 60 && sum <= 61)
                                    ? 1.07
                                    : 1;

                    for (var controller in controllers1) {
                      sum += int.parse(controller.text);
                    }
                    for (var controller in controllers2) {
                      sum += int.parse(controller.text);
                    }
                    sum += bool1[0] ? 1 : 0;
                    sum += bool1[1] ? 1 : 0;
                    sum += bool2[0] ? 1 : 0;
                    sum += bool2[1] ? 1 : 0;

                    sum *= factor;
                    sum += 10;
                    estmara["total"] = sum;

                    estmara["percent"] = sum / 196;
                    final FirebaseFirestore fireStore =
                        FirebaseFirestore.instance;
                    await fireStore
                        .collection(
                            "${widget.level == 0 ? Firebase.kgg : widget.level == 1 ? Firebase.olag : widget.level == 2 ? Firebase.taltag : Firebase.khamsag}result")
                        .add(estmara)
                        .then((val) {
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
