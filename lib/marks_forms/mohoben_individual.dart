import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:t7kem_al7an/constants/al7an.dart';

import '../widgets/marks_form_fields.dart';
import 'cubit/submit_cubit.dart';

class MohobenIndividual extends StatefulWidget {
  const MohobenIndividual(
      {super.key, required this.level, required this.churchName});

  final int level;
  final String churchName;

  @override
  State<MohobenIndividual> createState() => _MohobenIndividualState();
}

class _MohobenIndividualState extends State<MohobenIndividual> {
  final GlobalKey _globalKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  late List<TextEditingController> controllers1;
  late List<TextEditingController> controllers2;
  late List<TextEditingController> controllers3;
  late List<bool> bool1;
  late List<bool> bool2;
  late List<bool> bool3;
  late List<String> al7anList;

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
    controllers1 = List.generate(3, (_) => TextEditingController());
    controllers2 = List.generate(3, (_) => TextEditingController());
    controllers3 = List.generate(3, (_) => TextEditingController());
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
    return Scaffold(appBar: AppBar(
      title: Text(
        widget.level == 0
            ? "موهوبين فردى مرحلة حضانة"
            : widget.level == 1
            ? "موهوبين فردى مرحلة اولي وتانية"
            : widget.level == 2
            ? "موهوبين فردى مرحلة تالتة ورابعة"
            : "موهوبين فردى مرحلة خامسة وسادسة",
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
                      fontSize: 20, fontWeight: FontWeight.w500,color: Colors.indigo),
                ),
                const SizedBox(height: 10),
                MarksFormFields.mohobenIndividualForm(
                    al7anList[0], controllers1, bool1, (index, value) {
                  setState(() {
                    bool1[index] = value ?? false;
                  });
                },widget.level
                ),
                const SizedBox(height: 10),
                MarksFormFields.mohobenIndividualForm(
                    al7anList[1], controllers2, bool2, (index, value) {
                  setState(() {
                    bool2[index] = value ?? false;
                  });
                },widget.level),
                const SizedBox(height: 10),
                MarksFormFields.mohobenIndividualForm(
                    al7anList[2], controllers3, bool3, (index, value) {
                  setState(() {
                    bool3[index] = value ?? false;
                  });
                },widget.level),
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
                    }                  },
                  builder: (context, state) {
                    if (state is SubmitLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.indigo,),
                      );
                    }
                    return MarksFormFields.submitButton(onPressed: () {
                      context.read<SubmitCubit>().mohobenIndividual(
                        widget.churchName,
                        widget.level,
                        al7anList,
                        controllers1,
                        controllers2,
                        controllers3,
                        bool1,
                        bool2,
                        bool3,
                        _captureAndSave,

                      );
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
