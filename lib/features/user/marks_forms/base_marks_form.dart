import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/core/constants/al7an.dart';
import '/core/widgets/marks_form_fields.dart';

enum MarksFormKind {
  kg1,
  kg2,
  talta1,
  talta2,
  mohobenIndividual,
  mohobenGroup,
}

TextEditingController _textControllerFrom(dynamic value) {
  return TextEditingController(text: value?.toString() ?? '');
}

Map<String, dynamic> _mapValue(dynamic value) {
  return value is Map<String, dynamic> ? value : <String, dynamic>{};
}

bool _parseBoolValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

List<TextEditingController> _controllersForCategory(
  Map<String, dynamic> data,
  String hymnKey,
  List<String> scoreKeys,
) {
  final category = _mapValue(data[hymnKey]);
  return scoreKeys.map((key) => _textControllerFrom(category[key])).toList();
}

List<bool> _boolsForCategory(
  Map<String, dynamic> data,
  String hymnKey,
  List<String> boolKeys,
) {
  final category = _mapValue(data[hymnKey]);
  return boolKeys.map((key) => _parseBoolValue(category[key])).toList();
}

abstract class BaseMarksFormModel {
  BaseMarksFormModel({
    this.churchName,
    required this.levelInArabic,
  });

  String? churchName;
  final String levelInArabic;

  Widget view();
  bool validate();
  Map<String, dynamic> buildPayload(String judgeName);

  Future<bool> submit(String judgeName);
  void dispose();

  BaseMarksFormModel setChurchName(String name) {
    churchName = name;
    return this;
  }

  Future<bool> editSubmit({
    required String collectionName,
    required String documentId,
    required String judgeName,
  }) async {
    try {
      final payload = buildPayload(judgeName);
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .update(payload);
    } catch (e) {
      return false;
    }
    return true;
  }

  Widget _churchHeader() {
    return Text(
      churchName!,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.indigo,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _sectionGap([double height = 10]) => SizedBox(height: height);

  bool _isEmptyControllers(List<TextEditingController> controllers) {
    return controllers.any((controller) => controller.text.trim().isEmpty);
  }

  double _parseDouble(String value) =>
      double.tryParse(value.trim()) ?? double.nan;

  bool _withinRange(String value, double max) {
    final parsed = _parseDouble(value);
    return parsed.isFinite && parsed >= 0 && parsed <= max;
  }
}

class Kg1FormModel extends BaseMarksFormModel {
  Kg1FormModel({
    required super.churchName,
    required super.levelInArabic,
    bool isKg = true,
    List<L7n>? al7anList,
    List<TextEditingController>? controllers1,
    List<TextEditingController>? controllers2,
    List<TextEditingController>? controllers3,
    List<TextEditingController>? controllers4,
    TextEditingController? totalController,
    TextEditingController? slokController,
  })  : isKg = isKg,
        al7anList = al7anList ?? (isKg ? Al7an.kg1 : Al7an.ola1),
        controllers1 =
            controllers1 ?? List.generate(3, (_) => TextEditingController()),
        controllers2 =
            controllers2 ?? List.generate(3, (_) => TextEditingController()),
        controllers3 =
            controllers3 ?? List.generate(3, (_) => TextEditingController()),
        controllers4 =
            controllers4 ?? List.generate(3, (_) => TextEditingController()),
        totalController = totalController ?? TextEditingController(),
        slokController = slokController ?? TextEditingController(text: '10');

  final bool isKg;
  final List<L7n> al7anList;
  final List<TextEditingController> controllers1;
  final List<TextEditingController> controllers2;
  final List<TextEditingController> controllers3;
  final List<TextEditingController> controllers4;
  final TextEditingController totalController;
  final TextEditingController slokController;

  @override
  Widget view() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _churchHeader(),
        _sectionGap(),
        MarksFormFields.kgForm(al7anList[0], controllers1),
        _sectionGap(),
        MarksFormFields.kgForm(al7anList[1], controllers2),
        _sectionGap(),
        MarksFormFields.kgForm(al7anList[2], controllers3),
        _sectionGap(),
        MarksFormFields.kgForm(al7anList[3], controllers4),
        _sectionGap(),
        MarksFormFields.total(totalController),
        _sectionGap(),
        MarksFormFields.slok(slokController),
      ],
    );
  }

  @override
  bool validate() {
    if (totalController.text.trim().isEmpty ||
        slokController.text.trim().isEmpty) {
      return false;
    }
    if (!_withinRange(slokController.text, 10)) return false;
    final validations = [
      [20.0, 10.0, 10.0],
      [20.0, 10.0, 10.0],
      [20.0, 10.0, 10.0],
      [20.0, 10.0, 10.0],
    ];
    final controllerGroups = [
      controllers1,
      controllers2,
      controllers3,
      controllers4
    ];
    for (var i = 0; i < controllerGroups.length; i++) {
      if (_isEmptyControllers(controllerGroups[i])) return false;
      for (var j = 0; j < controllerGroups[i].length; j++) {
        if (!_withinRange(controllerGroups[i][j].text, validations[i][j]))
          return false;
      }
    }
    return true;
  }

  @override
  Map<String, dynamic> buildPayload(String judgeName) {
    final slok = _parseDouble(slokController.text);
    double sum = slok;
    for (final controller in [
      ...controllers1,
      ...controllers2,
      ...controllers3,
      ...controllers4,
    ]) {
      sum += _parseDouble(controller.text);
    }

    return {
      'churchName': churchName,
      'kidsTotal': totalController.text,
      'judge': judgeName,
      'slok': slok,
      al7anList[0].name: {
        Al7an.tslem: controllers1[0].text,
        Al7an.tempo: controllers1[1].text,
        Al7an.ro7ania: controllers1[2].text,
      },
      al7anList[1].name: {
        Al7an.tslem: controllers2[0].text,
        Al7an.tempo: controllers2[1].text,
        Al7an.ro7ania: controllers2[2].text,
      },
      al7anList[2].name: {
        Al7an.tslem: controllers3[0].text,
        Al7an.tempo: controllers3[1].text,
        Al7an.ro7ania: controllers3[2].text,
      },
      al7anList[3].name: {
        Al7an.tslem: controllers4[0].text,
        Al7an.tempo: controllers4[1].text,
        Al7an.ro7ania: controllers4[2].text,
      },
      'total': sum,
      'percent': sum / 174,
    };
  }

  @override
  void dispose() {
    for (final controller in [
      ...controllers1,
      ...controllers2,
      ...controllers3,
      ...controllers4,
      totalController,
      slokController,
    ]) {
      controller.dispose();
    }
  }

  @override
  Future<bool> submit(String judgeName) async {
    try {
      final payload = buildPayload(judgeName);
      final FirebaseFirestore fireStore = FirebaseFirestore.instance;
      await fireStore
          .collection(isKg ? "kg1ResultsFinal" : "oulaTanya1ResultsFinal")
          .add(payload);
    } catch (e) {
      return false;
    }
    return true;
  }

  static Kg1FormModel fromJson(
    Map<String, dynamic> data, {
    required bool isKg,
    required String levelInArabic,
  }) {
    final al7anList = isKg ? Al7an.kg1 : Al7an.ola1;
    return Kg1FormModel(
      churchName: data['churchName']?.toString(),
      levelInArabic: levelInArabic,
      isKg: isKg,
      al7anList: al7anList,
      controllers1: _controllersForCategory(
        data,
        al7anList[0].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania],
      ),
      controllers2: _controllersForCategory(
        data,
        al7anList[1].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania],
      ),
      controllers3: _controllersForCategory(
        data,
        al7anList[2].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania],
      ),
      controllers4: _controllersForCategory(
        data,
        al7anList[3].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania],
      ),
      totalController: _textControllerFrom(data['kidsTotal']),
      slokController: _textControllerFrom(data['slok'] ?? 10),
    );
  }
}

class Kg2FormModel extends BaseMarksFormModel {
  Kg2FormModel({
    required super.churchName,
    required super.levelInArabic,
    bool isKg = true,
    List<L7n>? al7anList,
    List<TextEditingController>? controllers1,
    List<TextEditingController>? controllers2,
    List<TextEditingController>? controllers3,
    List<TextEditingController>? controllers4,
    List<TextEditingController>? controllers5,
    List<TextEditingController>? controllers6,
    TextEditingController? totalController,
    TextEditingController? slokController,
  })  : isKg = isKg,
        al7anList = al7anList ?? (isKg ? Al7an.kg2 : Al7an.ola2),
        controllers1 =
            controllers1 ?? List.generate(3, (_) => TextEditingController()),
        controllers2 =
            controllers2 ?? List.generate(3, (_) => TextEditingController()),
        controllers3 =
            controllers3 ?? List.generate(3, (_) => TextEditingController()),
        controllers4 =
            controllers4 ?? List.generate(3, (_) => TextEditingController()),
        controllers5 =
            controllers5 ?? List.generate(3, (_) => TextEditingController()),
        controllers6 =
            controllers6 ?? List.generate(3, (_) => TextEditingController()),
        totalController = totalController ?? TextEditingController(),
        slokController = slokController ?? TextEditingController(text: '10');

  final bool isKg;
  final List<L7n> al7anList;
  final List<TextEditingController> controllers1;
  final List<TextEditingController> controllers2;
  final List<TextEditingController> controllers3;
  final List<TextEditingController> controllers4;
  final List<TextEditingController> controllers5;
  final List<TextEditingController> controllers6;
  final TextEditingController totalController;
  final TextEditingController slokController;

  @override
  Widget view() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _churchHeader(),
        _sectionGap(),
        MarksFormFields.kgForm(al7anList[0], controllers1),
        _sectionGap(),
        MarksFormFields.kgForm(al7anList[1], controllers2),
        _sectionGap(),
        MarksFormFields.kgForm(al7anList[2], controllers3),
        _sectionGap(),
        MarksFormFields.kgForm(al7anList[3], controllers4),
        _sectionGap(),
        MarksFormFields.kgForm(al7anList[4], controllers5),
        _sectionGap(),
        MarksFormFields.kgForm(al7anList[5], controllers6),
        _sectionGap(),
        MarksFormFields.total(totalController),
        _sectionGap(),
        MarksFormFields.slok(slokController),
      ],
    );
  }

  @override
  bool validate() {
    if (totalController.text.trim().isEmpty ||
        slokController.text.trim().isEmpty) {
      return false;
    }
    if (!_withinRange(slokController.text, 10)) return false;
    final controllerGroups = [
      controllers1,
      controllers2,
      controllers3,
      controllers4,
      controllers5,
      controllers6
    ];
    for (final group in controllerGroups) {
      if (_isEmptyControllers(group)) return false;
      final limits = [20.0, 10.0, 10.0];
      for (var i = 0; i < group.length; i++) {
        if (!_withinRange(group[i].text, limits[i])) return false;
      }
    }
    return true;
  }

  @override
  Map<String, dynamic> buildPayload(String judgeName) {
    final slok = _parseDouble(slokController.text);
    double sum = slok;
    for (final controller in [
      ...controllers1,
      ...controllers2,
      ...controllers3,
      ...controllers4,
      ...controllers5,
      ...controllers6,
    ]) {
      sum += _parseDouble(controller.text);
    }

    return {
      'churchName': churchName,
      'kidsTotal': totalController.text,
      'judge': judgeName,
      'slok': slok,
      al7anList[0].name: {
        Al7an.tslem: controllers1[0].text,
        Al7an.tempo: controllers1[1].text,
        Al7an.ro7ania: controllers1[2].text,
      },
      al7anList[1].name: {
        Al7an.tslem: controllers2[0].text,
        Al7an.tempo: controllers2[1].text,
        Al7an.ro7ania: controllers2[2].text,
      },
      al7anList[2].name: {
        Al7an.tslem: controllers3[0].text,
        Al7an.tempo: controllers3[1].text,
        Al7an.ro7ania: controllers3[2].text,
      },
      al7anList[3].name: {
        Al7an.tslem: controllers4[0].text,
        Al7an.tempo: controllers4[1].text,
        Al7an.ro7ania: controllers4[2].text,
      },
      al7anList[4].name: {
        Al7an.tslem: controllers5[0].text,
        Al7an.tempo: controllers5[1].text,
        Al7an.ro7ania: controllers5[2].text,
      },
      al7anList[5].name: {
        Al7an.tslem: controllers6[0].text,
        Al7an.tempo: controllers6[1].text,
        Al7an.ro7ania: controllers6[2].text,
      },
      'total': sum,
      'percent': sum / 256,
    };
  }

  @override
  void dispose() {
    for (final controller in [
      ...controllers1,
      ...controllers2,
      ...controllers3,
      ...controllers4,
      ...controllers5,
      ...controllers6,
      totalController,
      slokController,
    ]) {
      controller.dispose();
    }
  }

  @override
  Future<bool> submit(String judgeName) async {
    final payload = buildPayload(judgeName);
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    await fireStore
        .collection(isKg ? "kg2ResultsFinal" : "oulaTanya2ResultsFinal")
        .add(payload);
    return true;
  }

  static Kg2FormModel fromJson(
    Map<String, dynamic> data, {
    required bool isKg,
    required String levelInArabic,
  }) {
    final al7anList = isKg ? Al7an.kg2 : Al7an.ola2;
    return Kg2FormModel(
      churchName: data['churchName']?.toString(),
      levelInArabic: levelInArabic,
      isKg: isKg,
      al7anList: al7anList,
      controllers1: _controllersForCategory(
        data,
        al7anList[0].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania],
      ),
      controllers2: _controllersForCategory(
        data,
        al7anList[1].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania],
      ),
      controllers3: _controllersForCategory(
        data,
        al7anList[2].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania],
      ),
      controllers4: _controllersForCategory(
        data,
        al7anList[3].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania],
      ),
      controllers5: _controllersForCategory(
        data,
        al7anList[4].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania],
      ),
      controllers6: _controllersForCategory(
        data,
        al7anList[5].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania],
      ),
      totalController: _textControllerFrom(data['kidsTotal']),
      slokController: _textControllerFrom(data['slok'] ?? 10),
    );
  }
}

class Talta1FormModel extends BaseMarksFormModel {
  Talta1FormModel({
    required super.churchName,
    required super.levelInArabic,
    bool isTalta = true,
    List<L7n>? al7anList,
    List<TextEditingController>? controllers1,
    List<TextEditingController>? controllers2,
    List<TextEditingController>? controllers3,
    List<TextEditingController>? controllers4,
    TextEditingController? totalController,
    TextEditingController? copticReadingController,
    TextEditingController? taksController,
    TextEditingController? slokController,
    List<bool>? bool1,
    List<bool>? bool2,
    List<bool>? bool3,
    List<bool>? bool4,
  })  : isTalta = isTalta,
        al7anList = al7anList ?? (isTalta ? Al7an.talta1 : Al7an.khamsa1),
        controllers1 =
            controllers1 ?? List.generate(4, (_) => TextEditingController()),
        controllers2 =
            controllers2 ?? List.generate(4, (_) => TextEditingController()),
        controllers3 =
            controllers3 ?? List.generate(4, (_) => TextEditingController()),
        controllers4 =
            controllers4 ?? List.generate(4, (_) => TextEditingController()),
        totalController = totalController ?? TextEditingController(),
        copticReadingController =
            copticReadingController ?? TextEditingController(),
        taksController = taksController ?? TextEditingController(),
        slokController = slokController ?? TextEditingController(text: '10'),
        bool1 = bool1 ?? List.generate(3, (_) => false),
        bool2 = bool2 ?? List.generate(3, (_) => false),
        bool3 = bool3 ?? List.generate(3, (_) => false),
        bool4 = bool4 ?? List.generate(3, (_) => false);

  final bool isTalta;
  final List<L7n> al7anList;
  final List<TextEditingController> controllers1;
  final List<TextEditingController> controllers2;
  final List<TextEditingController> controllers3;
  final List<TextEditingController> controllers4;
  final TextEditingController totalController;
  final TextEditingController copticReadingController;
  final TextEditingController taksController;
  final TextEditingController slokController;
  final List<bool> bool1;
  final List<bool> bool2;
  final List<bool> bool3;
  final List<bool> bool4;

  @override
  Widget view() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _churchHeader(),
            _sectionGap(),
            MarksFormFields.taltaForm(al7anList[0], controllers1, bool1,
                (index, value) {
              setState(() => bool1[index] = value ?? false);
            }),
            _sectionGap(),
            MarksFormFields.taltaForm(al7anList[1], controllers2, bool2,
                (index, value) {
              setState(() => bool2[index] = value ?? false);
            }),
            _sectionGap(),
            MarksFormFields.taltaForm(al7anList[2], controllers3, bool3,
                (index, value) {
              setState(() => bool3[index] = value ?? false);
            }),
            _sectionGap(),
            MarksFormFields.taltaForm(al7anList[3], controllers4, bool4,
                (index, value) {
              setState(() => bool4[index] = value ?? false);
            }),
            _sectionGap(),
            MarksFormFields.taks(taksController, 4),
            _sectionGap(),
            MarksFormFields.copticReading(copticReadingController),
            _sectionGap(),
            MarksFormFields.total(totalController),
            _sectionGap(),
            MarksFormFields.slok(slokController),
          ],
        );
      },
    );
  }

  @override
  bool validate() {
    final requiredControllers = [
      ...controllers1,
      ...controllers2,
      ...controllers3,
      ...controllers4,
      taksController,
      copticReadingController,
      totalController,
      slokController,
    ];
    if (requiredControllers.any((c) => c.text.trim().isEmpty)) return false;
    if (!_withinRange(copticReadingController.text, 5)) return false;
    if (!_withinRange(taksController.text, 4)) return false;
    if (!_withinRange(slokController.text, 10)) return false;

    final limits = [20.0, 10.0, 10.0, 10.0];
    for (final group in [
      controllers1,
      controllers2,
      controllers3,
      controllers4
    ]) {
      for (var i = 0; i < group.length; i++) {
        if (!_withinRange(group[i].text, limits[i])) return false;
      }
    }
    return true;
  }

  @override
  Map<String, dynamic> buildPayload(String judgeName) {
    final slok = _parseDouble(slokController.text);
    final taks = _parseDouble(taksController.text);
    final copticReading = _parseDouble(copticReadingController.text);
    double sum = slok;

    for (final controller in [
      ...controllers1,
      ...controllers2,
      ...controllers3,
      ...controllers4,
    ]) {
      sum += _parseDouble(controller.text);
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
    sum += taks;
    sum += copticReading;

    return {
      'churchName': churchName,
      'kidsTotal': totalController.text,
      'judge': judgeName,
      'slok': slok,
      'taks': taks,
      'copticReading': copticReading,
      al7anList[0].name: {
        Al7an.tslem: controllers1[0].text,
        Al7an.tempo: controllers1[1].text,
        Al7an.ro7ania: controllers1[2].text,
        Al7an.copticSpelling: controllers1[3].text,
        Al7an.df: bool1[0],
        Al7an.treanto: bool1[1],
        Al7an.hzat: bool1[2],
      },
      al7anList[1].name: {
        Al7an.tslem: controllers2[0].text,
        Al7an.tempo: controllers2[1].text,
        Al7an.ro7ania: controllers2[2].text,
        Al7an.copticSpelling: controllers2[3].text,
        Al7an.df: bool2[0],
        Al7an.treanto: bool2[1],
        Al7an.hzat: bool2[2],
      },
      al7anList[2].name: {
        Al7an.tslem: controllers3[0].text,
        Al7an.tempo: controllers3[1].text,
        Al7an.ro7ania: controllers3[2].text,
        Al7an.copticSpelling: controllers3[3].text,
        Al7an.df: bool3[0],
        Al7an.treanto: bool3[1],
        Al7an.hzat: bool3[2],
      },
      al7anList[3].name: {
        Al7an.tslem: controllers4[0].text,
        Al7an.tempo: controllers4[1].text,
        Al7an.ro7ania: controllers4[2].text,
        Al7an.copticSpelling: controllers4[3].text,
        Al7an.df: bool4[0],
        Al7an.treanto: bool4[1],
        Al7an.hzat: bool4[2],
      },
      'total': sum,
      'percent': sum / 227,
    };
  }

  @override
  void dispose() {
    for (final controller in [
      ...controllers1,
      ...controllers2,
      ...controllers3,
      ...controllers4,
      totalController,
      copticReadingController,
      taksController,
      slokController,
    ]) {
      controller.dispose();
    }
  }

  @override
  Future<bool> submit(String judgeName) async {
    final payload = buildPayload(judgeName);
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    await fireStore
        .collection(
            isTalta ? "taltaRaba1ResultsFinal" : "khamsaSadsa1ResultsFinal")
        .add(payload);
    return true;
  }

  static Talta1FormModel fromJson(
    Map<String, dynamic> data, {
    required bool isTalta,
    required String levelInArabic,
  }) {
    final al7anList = isTalta ? Al7an.talta1 : Al7an.khamsa1;
    return Talta1FormModel(
      churchName: data['churchName']?.toString(),
      levelInArabic: levelInArabic,
      isTalta: isTalta,
      al7anList: al7anList,
      controllers1: _controllersForCategory(
        data,
        al7anList[0].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania, Al7an.copticSpelling],
      ),
      controllers2: _controllersForCategory(
        data,
        al7anList[1].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania, Al7an.copticSpelling],
      ),
      controllers3: _controllersForCategory(
        data,
        al7anList[2].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania, Al7an.copticSpelling],
      ),
      controllers4: _controllersForCategory(
        data,
        al7anList[3].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania, Al7an.copticSpelling],
      ),
      bool1: _boolsForCategory(
        data,
        al7anList[0].name,
        [Al7an.df, Al7an.treanto, Al7an.hzat],
      ),
      bool2: _boolsForCategory(
        data,
        al7anList[1].name,
        [Al7an.df, Al7an.treanto, Al7an.hzat],
      ),
      bool3: _boolsForCategory(
        data,
        al7anList[2].name,
        [Al7an.df, Al7an.treanto, Al7an.hzat],
      ),
      bool4: _boolsForCategory(
        data,
        al7anList[3].name,
        [Al7an.df, Al7an.treanto, Al7an.hzat],
      ),
      totalController: _textControllerFrom(data['kidsTotal']),
      copticReadingController: _textControllerFrom(data['copticReading']),
      taksController: _textControllerFrom(data['taks']),
      slokController: _textControllerFrom(data['slok'] ?? 10),
    );
  }
}

class Talta2FormModel extends BaseMarksFormModel {
  Talta2FormModel({
    required super.churchName,
    required super.levelInArabic,
    bool isTalta = true,
    List<L7n>? al7anList,
    List<TextEditingController>? controllers1,
    List<TextEditingController>? controllers2,
    List<TextEditingController>? controllers3,
    List<TextEditingController>? controllers4,
    List<TextEditingController>? controllers5,
    List<TextEditingController>? controllers6,
    TextEditingController? totalController,
    TextEditingController? taksController,
    TextEditingController? slokController,
    List<bool>? bool1,
    List<bool>? bool2,
    List<bool>? bool3,
    List<bool>? bool4,
    List<bool>? bool5,
    List<bool>? bool6,
  })  : isTalta = isTalta,
        al7anList = al7anList ?? (isTalta ? Al7an.talta2 : Al7an.khamsa2),
        controllers1 =
            controllers1 ?? List.generate(4, (_) => TextEditingController()),
        controllers2 =
            controllers2 ?? List.generate(4, (_) => TextEditingController()),
        controllers3 =
            controllers3 ?? List.generate(4, (_) => TextEditingController()),
        controllers4 =
            controllers4 ?? List.generate(4, (_) => TextEditingController()),
        controllers5 =
            controllers5 ?? List.generate(4, (_) => TextEditingController()),
        controllers6 =
            controllers6 ?? List.generate(4, (_) => TextEditingController()),
        totalController = totalController ?? TextEditingController(),
        taksController = taksController ?? TextEditingController(),
        slokController = slokController ?? TextEditingController(text: '10'),
        bool1 = bool1 ?? List.generate(3, (_) => false),
        bool2 = bool2 ?? List.generate(3, (_) => false),
        bool3 = bool3 ?? List.generate(3, (_) => false),
        bool4 = bool4 ?? List.generate(3, (_) => false),
        bool5 = bool5 ?? List.generate(3, (_) => false),
        bool6 = bool6 ?? List.generate(3, (_) => false);

  final bool isTalta;
  final List<L7n> al7anList;
  final List<TextEditingController> controllers1;
  final List<TextEditingController> controllers2;
  final List<TextEditingController> controllers3;
  final List<TextEditingController> controllers4;
  final List<TextEditingController> controllers5;
  final List<TextEditingController> controllers6;
  final TextEditingController totalController;
  final TextEditingController taksController;
  final TextEditingController slokController;
  final List<bool> bool1;
  final List<bool> bool2;
  final List<bool> bool3;
  final List<bool> bool4;
  final List<bool> bool5;
  final List<bool> bool6;

  @override
  Widget view() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _churchHeader(),
            _sectionGap(),
            MarksFormFields.taltaForm(al7anList[0], controllers1, bool1,
                (index, value) {
              setState(() => bool1[index] = value ?? false);
            }),
            _sectionGap(),
            MarksFormFields.taltaForm(al7anList[1], controllers2, bool2,
                (index, value) {
              setState(() => bool2[index] = value ?? false);
            }),
            _sectionGap(),
            MarksFormFields.taltaForm(al7anList[2], controllers3, bool3,
                (index, value) {
              setState(() => bool3[index] = value ?? false);
            }),
            _sectionGap(),
            MarksFormFields.taltaForm(al7anList[3], controllers4, bool4,
                (index, value) {
              setState(() => bool4[index] = value ?? false);
            }),
            _sectionGap(),
            MarksFormFields.taltaForm(al7anList[4], controllers5, bool5,
                (index, value) {
              setState(() => bool5[index] = value ?? false);
            }),
            _sectionGap(),
            MarksFormFields.taltaForm(al7anList[5], controllers6, bool6,
                (index, value) {
              setState(() => bool6[index] = value ?? false);
            }),
            _sectionGap(),
            MarksFormFields.taks(taksController, 6),
            _sectionGap(),
            MarksFormFields.total(totalController),
            _sectionGap(),
            MarksFormFields.slok(slokController),
          ],
        );
      },
    );
  }

  @override
  bool validate() {
    final requiredControllers = [
      ...controllers1,
      ...controllers2,
      ...controllers3,
      ...controllers4,
      ...controllers5,
      ...controllers6,
      taksController,
      totalController,
      slokController,
    ];
    if (requiredControllers.any((c) => c.text.trim().isEmpty)) return false;
    if (!_withinRange(taksController.text, 6)) return false;
    if (!_withinRange(slokController.text, 10)) return false;

    final limits = [20.0, 10.0, 10.0, 10.0];
    for (final group in [
      controllers1,
      controllers2,
      controllers3,
      controllers4,
      controllers5,
      controllers6
    ]) {
      for (var i = 0; i < group.length; i++) {
        if (!_withinRange(group[i].text, limits[i])) return false;
      }
    }
    return true;
  }

  @override
  Map<String, dynamic> buildPayload(String judgeName) {
    final slok = _parseDouble(slokController.text);
    final taks = _parseDouble(taksController.text);
    double sum = slok;

    for (final controller in [
      ...controllers1,
      ...controllers2,
      ...controllers3,
      ...controllers4,
      ...controllers5,
      ...controllers6,
    ]) {
      sum += _parseDouble(controller.text);
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
    sum += taks;

    return {
      'churchName': churchName,
      'kidsTotal': totalController.text,
      'judge': judgeName,
      'slok': slok,
      'taks': taks,
      al7anList[0].name: {
        Al7an.tslem: controllers1[0].text,
        Al7an.tempo: controllers1[1].text,
        Al7an.ro7ania: controllers1[2].text,
        Al7an.copticSpelling: controllers1[3].text,
        Al7an.df: bool1[0],
        Al7an.treanto: bool1[1],
        Al7an.hzat: bool1[2],
      },
      al7anList[1].name: {
        Al7an.tslem: controllers2[0].text,
        Al7an.tempo: controllers2[1].text,
        Al7an.ro7ania: controllers2[2].text,
        Al7an.copticSpelling: controllers2[3].text,
        Al7an.df: bool2[0],
        Al7an.treanto: bool2[1],
        Al7an.hzat: bool2[2],
      },
      al7anList[2].name: {
        Al7an.tslem: controllers3[0].text,
        Al7an.tempo: controllers3[1].text,
        Al7an.ro7ania: controllers3[2].text,
        Al7an.copticSpelling: controllers3[3].text,
        Al7an.df: bool3[0],
        Al7an.treanto: bool3[1],
        Al7an.hzat: bool3[2],
      },
      al7anList[3].name: {
        Al7an.tslem: controllers4[0].text,
        Al7an.tempo: controllers4[1].text,
        Al7an.ro7ania: controllers4[2].text,
        Al7an.copticSpelling: controllers4[3].text,
        Al7an.df: bool4[0],
        Al7an.treanto: bool4[1],
        Al7an.hzat: bool4[2],
      },
      al7anList[4].name: {
        Al7an.tslem: controllers5[0].text,
        Al7an.tempo: controllers5[1].text,
        Al7an.ro7ania: controllers5[2].text,
        Al7an.copticSpelling: controllers5[3].text,
        Al7an.df: bool5[0],
        Al7an.treanto: bool5[1],
        Al7an.hzat: bool5[2],
      },
      al7anList[5].name: {
        Al7an.tslem: controllers6[0].text,
        Al7an.tempo: controllers6[1].text,
        Al7an.ro7ania: controllers6[2].text,
        Al7an.copticSpelling: controllers6[3].text,
        Al7an.df: bool6[0],
        Al7an.treanto: bool6[1],
        Al7an.hzat: bool6[2],
      },
      'total': sum,
      'percent': sum / 328,
    };
  }

  @override
  void dispose() {
    for (final controller in [
      ...controllers1,
      ...controllers2,
      ...controllers3,
      ...controllers4,
      ...controllers5,
      ...controllers6,
      totalController,
      taksController,
      slokController,
    ]) {
      controller.dispose();
    }
  }

  @override
  Future<bool> submit(String judgeName) async {
    final payload = buildPayload(judgeName);
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    await fireStore
        .collection(
            isTalta ? "taltaRaba2ResultsFinal" : "khamsaSadsa2ResultsFinal")
        .add(payload);
    return true;
  }

  static Talta2FormModel fromJson(
    Map<String, dynamic> data, {
    required bool isTalta,
    required String levelInArabic,
  }) {
    final al7anList = isTalta ? Al7an.talta2 : Al7an.khamsa2;
    return Talta2FormModel(
      churchName: data['churchName']?.toString(),
      levelInArabic: levelInArabic,
      isTalta: isTalta,
      al7anList: al7anList,
      controllers1: _controllersForCategory(
        data,
        al7anList[0].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania, Al7an.copticSpelling],
      ),
      controllers2: _controllersForCategory(
        data,
        al7anList[1].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania, Al7an.copticSpelling],
      ),
      controllers3: _controllersForCategory(
        data,
        al7anList[2].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania, Al7an.copticSpelling],
      ),
      controllers4: _controllersForCategory(
        data,
        al7anList[3].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania, Al7an.copticSpelling],
      ),
      controllers5: _controllersForCategory(
        data,
        al7anList[4].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania, Al7an.copticSpelling],
      ),
      controllers6: _controllersForCategory(
        data,
        al7anList[5].name,
        [Al7an.tslem, Al7an.tempo, Al7an.ro7ania, Al7an.copticSpelling],
      ),
      bool1: _boolsForCategory(
        data,
        al7anList[0].name,
        [Al7an.df, Al7an.treanto, Al7an.hzat],
      ),
      bool2: _boolsForCategory(
        data,
        al7anList[1].name,
        [Al7an.df, Al7an.treanto, Al7an.hzat],
      ),
      bool3: _boolsForCategory(
        data,
        al7anList[2].name,
        [Al7an.df, Al7an.treanto, Al7an.hzat],
      ),
      bool4: _boolsForCategory(
        data,
        al7anList[3].name,
        [Al7an.df, Al7an.treanto, Al7an.hzat],
      ),
      bool5: _boolsForCategory(
        data,
        al7anList[4].name,
        [Al7an.df, Al7an.treanto, Al7an.hzat],
      ),
      bool6: _boolsForCategory(
        data,
        al7anList[5].name,
        [Al7an.df, Al7an.treanto, Al7an.hzat],
      ),
      totalController: _textControllerFrom(data['kidsTotal']),
      taksController: _textControllerFrom(data['taks']),
      slokController: _textControllerFrom(data['slok'] ?? 10),
    );
  }
}

class MohobenIndividualFormModel extends BaseMarksFormModel {
  MohobenIndividualFormModel({
    required super.churchName,
    required super.levelInArabic,
    required this.level,
    List<L7n>? al7anList,
    List<TextEditingController>? controllers1,
    List<TextEditingController>? controllers2,
    List<TextEditingController>? controllers3,
    List<bool>? bool1,
    List<bool>? bool2,
    List<bool>? bool3,
  })  : al7anList = al7anList ??
            (level == 0
                ? Al7an.kg3
                : level == 1
                    ? Al7an.ola3
                    : level == 2
                        ? Al7an.talta3
                        : Al7an.khamsa3),
        controllers1 =
            controllers1 ?? List.generate(3, (_) => TextEditingController()),
        controllers2 =
            controllers2 ?? List.generate(3, (_) => TextEditingController()),
        controllers3 =
            controllers3 ?? List.generate(3, (_) => TextEditingController()),
        bool1 = bool1 ?? List.generate(2, (_) => false),
        bool2 = bool2 ?? List.generate(2, (_) => false),
        bool3 = bool3 ?? List.generate(2, (_) => false);

  final int level;
  final List<L7n> al7anList;
  final List<TextEditingController> controllers1;
  final List<TextEditingController> controllers2;
  final List<TextEditingController> controllers3;
  final List<bool> bool1;
  final List<bool> bool2;
  final List<bool> bool3;

  @override
  Widget view() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _churchHeader(),
            _sectionGap(),
            MarksFormFields.mohobenIndividualForm(
                al7anList[0], controllers1, bool1, (index, value) {
              setState(() => bool1[index] = value ?? false);
            }, level),
            _sectionGap(),
            MarksFormFields.mohobenIndividualForm(
                al7anList[1], controllers2, bool2, (index, value) {
              setState(() => bool2[index] = value ?? false);
            }, level),
            _sectionGap(),
            MarksFormFields.mohobenIndividualForm(
                al7anList[2], controllers3, bool3, (index, value) {
              setState(() => bool3[index] = value ?? false);
            }, level),
          ],
        );
      },
    );
  }

  @override
  bool validate() {
    final controllerGroups = [controllers1, controllers2, controllers3];
    final limits = [15.0, 10.0, 10.0];
    for (final group in controllerGroups) {
      if (_isEmptyControllers(group)) return false;
      for (var i = 0; i < group.length; i++) {
        if (!_withinRange(group[i].text, limits[i])) return false;
      }
    }
    return true;
  }

  @override
  Map<String, dynamic> buildPayload(String judgeName) {
    double sum = 0;
    for (final controller in controllers3) {
      sum += _parseDouble(controller.text);
    }
    sum += bool3[0] ? 1 : 0;
    sum += bool3[1] ? 1 : 0;
    final factor = (sum >= 50 && sum <= 53)
        ? 1.01
        : (sum >= 54 && sum <= 56)
            ? 1.02
            : (sum >= 57 && sum <= 59)
                ? 1.05
                : (sum >= 60 && sum <= 61)
                    ? 1.07
                    : 1.0;

    for (final controller in [...controllers1, ...controllers2]) {
      sum += _parseDouble(controller.text);
    }

    sum += bool1[0] ? 1 : 0;
    sum += bool1[1] ? 1 : 0;
    sum += bool2[0] ? 1 : 0;
    sum += bool2[1] ? 1 : 0;
    sum *= factor;

    return {
      'churchName': churchName,
      'judge': judgeName,
      al7anList[0].name: {
        Al7an.tslem: controllers1[0].text,
        Al7an.copticReading: controllers1[1].text,
        Al7an.ro7ania: controllers1[2].text,
        Al7an.taks: bool1[0],
        Al7an.df: bool1[1],
      },
      al7anList[1].name: {
        Al7an.tslem: controllers2[0].text,
        Al7an.copticReading: controllers2[1].text,
        Al7an.ro7ania: controllers2[2].text,
        Al7an.taks: bool2[0],
        Al7an.df: bool2[1],
      },
      al7anList[2].name: {
        Al7an.tslem: controllers3[0].text,
        Al7an.copticReading: controllers3[1].text,
        Al7an.ro7ania: controllers3[2].text,
        Al7an.taks: bool3[0],
        Al7an.df: bool3[1],
      },
      'total': sum,
      'percent': sum / 111,
    };
  }

  @override
  void dispose() {
    for (final controller in [
      ...controllers1,
      ...controllers2,
      ...controllers3
    ]) {
      controller.dispose();
    }
  }

  @override
  Future<bool> submit(String judgeName) async {
    final payload = buildPayload(judgeName);
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    await fireStore
        .collection(level == 0
            ? "kgFResultsFinal"
            : level == 1
                ? "oulaTanyaFResultsFinal"
                : level == 2
                    ? "taltaRabaFResultsFinal"
                    : "khamsaSadsaFResultsFinal")
        .add(payload);
    return true;
  }

  static MohobenIndividualFormModel fromJson(
    Map<String, dynamic> data, {
    required int level,
    required String levelInArabic,
  }) {
    final al7anList = level == 0
        ? Al7an.kg3
        : level == 1
            ? Al7an.ola3
            : level == 2
                ? Al7an.talta3
                : Al7an.khamsa3;
    return MohobenIndividualFormModel(
      churchName: data['churchName']?.toString(),
      levelInArabic: levelInArabic,
      level: level,
      al7anList: al7anList,
      controllers1: _controllersForCategory(
        data,
        al7anList[0].name,
        [Al7an.tslem, Al7an.copticReading, Al7an.ro7ania],
      ),
      controllers2: _controllersForCategory(
        data,
        al7anList[1].name,
        [Al7an.tslem, Al7an.copticReading, Al7an.ro7ania],
      ),
      controllers3: _controllersForCategory(
        data,
        al7anList[2].name,
        [Al7an.tslem, Al7an.copticReading, Al7an.ro7ania],
      ),
      bool1: _boolsForCategory(
        data,
        al7anList[0].name,
        [Al7an.taks, Al7an.df],
      ),
      bool2: _boolsForCategory(
        data,
        al7anList[1].name,
        [Al7an.taks, Al7an.df],
      ),
      bool3: _boolsForCategory(
        data,
        al7anList[2].name,
        [Al7an.taks, Al7an.df],
      ),
    );
  }
}

class MohobenGroupFormModel extends BaseMarksFormModel {
  MohobenGroupFormModel({
    required super.churchName,
    required super.levelInArabic,
    required this.level,
    List<L7n>? al7anList,
    List<TextEditingController>? controllers1,
    List<TextEditingController>? controllers2,
    List<TextEditingController>? controllers3,
    TextEditingController? totalController,
    TextEditingController? slokController,
    List<bool>? bool1,
    List<bool>? bool2,
    List<bool>? bool3,
  })  : al7anList = al7anList ??
            (level == 0
                ? Al7an.kg3
                : level == 1
                    ? Al7an.ola3
                    : level == 2
                        ? Al7an.talta3
                        : Al7an.khamsa3),
        controllers1 =
            controllers1 ?? List.generate(5, (_) => TextEditingController()),
        controllers2 =
            controllers2 ?? List.generate(5, (_) => TextEditingController()),
        controllers3 =
            controllers3 ?? List.generate(5, (_) => TextEditingController()),
        totalController = totalController ?? TextEditingController(),
        slokController = slokController ?? TextEditingController(text: '10'),
        bool1 = bool1 ?? List.generate(3, (_) => false),
        bool2 = bool2 ?? List.generate(3, (_) => false),
        bool3 = bool3 ?? List.generate(3, (_) => false);

  final int level;
  final List<L7n> al7anList;
  final List<TextEditingController> controllers1;
  final List<TextEditingController> controllers2;
  final List<TextEditingController> controllers3;
  final TextEditingController totalController;
  final TextEditingController slokController;
  final List<bool> bool1;
  final List<bool> bool2;
  final List<bool> bool3;

  @override
  Widget view() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _churchHeader(),
            _sectionGap(),
            MarksFormFields.mohobenGroupForm(al7anList[0], controllers1, bool1,
                (index, value) {
              setState(() => bool1[index] = value ?? false);
            }, level),
            _sectionGap(20),
            MarksFormFields.mohobenGroupForm(al7anList[1], controllers2, bool2,
                (index, value) {
              setState(() => bool2[index] = value ?? false);
            }, level),
            _sectionGap(20),
            MarksFormFields.mohobenGroupForm(al7anList[2], controllers3, bool3,
                (index, value) {
              setState(() => bool3[index] = value ?? false);
            }, level),
            _sectionGap(),
            MarksFormFields.total(totalController),
            _sectionGap(),
            MarksFormFields.slok(slokController),
          ],
        );
      },
    );
  }

  @override
  bool validate() {
    if (totalController.text.trim().isEmpty ||
        slokController.text.trim().isEmpty) return false;
    if (!_withinRange(slokController.text, 10)) return false;
    final controllerGroups = [controllers1, controllers2, controllers3];
    for (final group in controllerGroups) {
      if (_isEmptyControllers(group)) return false;
      final limits = [20.0, 10.0, 10.0, 10.0, 10.0];
      for (var i = 0; i < group.length; i++) {
        if (!_withinRange(group[i].text, limits[i])) return false;
      }
    }
    return true;
  }

  @override
  Map<String, dynamic> buildPayload(String judgeName) {
    final slok = _parseDouble(slokController.text);
    double sum = 0;

    for (final controller in controllers3) {
      sum += _parseDouble(controller.text);
    }
    sum += bool3[0] ? 1 : 0;
    sum += bool3[1] ? .5 : 0;
    sum += bool3[2] ? .5 : 0;

    final factor = (sum >= 50 && sum <= 53)
        ? 1.01
        : (sum >= 54 && sum <= 56)
            ? 1.02
            : (sum >= 57 && sum <= 59)
                ? 1.05
                : (sum >= 60 && sum <= 61)
                    ? 1.07
                    : 1.0;

    for (final controller in [...controllers1, ...controllers2]) {
      sum += _parseDouble(controller.text);
    }

    sum += bool1[0] ? 1 : 0;
    sum += bool1[1] ? .5 : 0;
    sum += bool1[2] ? .5 : 0;
    sum += bool2[0] ? 1 : 0;
    sum += bool2[1] ? .5 : 0;
    sum += bool2[2] ? .5 : 0;
    sum *= factor;
    sum += slok;

    return {
      'churchName': churchName,
      'kidsTotal': totalController.text,
      'judge': judgeName,
      'slok': slok,
      al7anList[0].name: {
        Al7an.tslem: controllers1[0].text,
        Al7an.tempo: controllers1[1].text,
        Al7an.tnas2: controllers1[2].text,
        Al7an.copticReading: controllers1[3].text,
        Al7an.ro7ania: controllers1[4].text,
        Al7an.taks: bool1[0],
        Al7an.df: bool1[1],
        Al7an.treanto: bool1[2],
      },
      al7anList[1].name: {
        Al7an.tslem: controllers2[0].text,
        Al7an.tempo: controllers2[1].text,
        Al7an.tnas2: controllers2[2].text,
        Al7an.copticReading: controllers2[3].text,
        Al7an.ro7ania: controllers2[4].text,
        Al7an.taks: bool2[0],
        Al7an.df: bool2[1],
        Al7an.treanto: bool2[2],
      },
      al7anList[2].name: {
        Al7an.tslem: controllers3[0].text,
        Al7an.tempo: controllers3[1].text,
        Al7an.tnas2: controllers3[2].text,
        Al7an.copticReading: controllers3[3].text,
        Al7an.ro7ania: controllers3[4].text,
        Al7an.taks: bool3[0],
        Al7an.df: bool3[1],
        Al7an.treanto: bool3[2],
      },
      'total': sum,
      'percent': sum / 196,
    };
  }

  @override
  void dispose() {
    for (final controller in [
      ...controllers1,
      ...controllers2,
      ...controllers3,
      totalController,
      slokController
    ]) {
      controller.dispose();
    }
  }

  @override
  Future<bool> submit(String judgeName) async {
    final payload = buildPayload(judgeName);
    final FirebaseFirestore fireStore = FirebaseFirestore.instance;
    await fireStore
        .collection(level == 0
            ? "kgGResultsFinal"
            : level == 1
                ? "oulaTanyaGResultsFinal"
                : level == 2
                    ? "taltaRabaGResultsFinal"
                    : "khamsaSadsaGResultsFinal")
        .add(payload);
    return true;
  }

  static MohobenGroupFormModel fromJson(
    Map<String, dynamic> data, {
    required int level,
    required String levelInArabic,
  }) {
    final al7anList = level == 0
        ? Al7an.kg3
        : level == 1
            ? Al7an.ola3
            : level == 2
                ? Al7an.talta3
                : Al7an.khamsa3;
    return MohobenGroupFormModel(
      churchName: data['churchName']?.toString(),
      levelInArabic: levelInArabic,
      level: level,
      al7anList: al7anList,
      controllers1: _controllersForCategory(
        data,
        al7anList[0].name,
        [
          Al7an.tslem,
          Al7an.tempo,
          Al7an.tnas2,
          Al7an.copticReading,
          Al7an.ro7ania
        ],
      ),
      controllers2: _controllersForCategory(
        data,
        al7anList[1].name,
        [
          Al7an.tslem,
          Al7an.tempo,
          Al7an.tnas2,
          Al7an.copticReading,
          Al7an.ro7ania
        ],
      ),
      controllers3: _controllersForCategory(
        data,
        al7anList[2].name,
        [
          Al7an.tslem,
          Al7an.tempo,
          Al7an.tnas2,
          Al7an.copticReading,
          Al7an.ro7ania
        ],
      ),
      bool1: _boolsForCategory(
        data,
        al7anList[0].name,
        [Al7an.taks, Al7an.df, Al7an.treanto],
      ),
      bool2: _boolsForCategory(
        data,
        al7anList[1].name,
        [Al7an.taks, Al7an.df, Al7an.treanto],
      ),
      bool3: _boolsForCategory(
        data,
        al7anList[2].name,
        [Al7an.taks, Al7an.df, Al7an.treanto],
      ),
      totalController: _textControllerFrom(data['kidsTotal']),
      slokController: _textControllerFrom(data['slok'] ?? 10),
    );
  }
}

// class MarksFormFactory {
//   static BaseMarksFormModel create(
// 	MarksFormKind kind, {
// 	required String churchName,
// 	bool? isKg,
// 	bool? isTalta,
// 	int? level,
// 	SubmissionHandler? onSubmit,
//   }) {
// 	switch (kind) {
// 	  case MarksFormKind.kg1:
// 		return Kg1FormModel(churchName: churchName, isKg: isKg ?? true, onSubmit: onSubmit);
// 	  case MarksFormKind.kg2:
// 		return Kg2FormModel(churchName: churchName, isKg: isKg ?? true, onSubmit: onSubmit);
// 	  case MarksFormKind.talta1:
// 		return Talta1FormModel(churchName: churchName, isTalta: isTalta ?? true, onSubmit: onSubmit);
// 	  case MarksFormKind.talta2:
// 		return Talta2FormModel(churchName: churchName, isTalta: isTalta ?? true, onSubmit: onSubmit);
// 	  case MarksFormKind.mohobenIndividual:
// 		return MohobenIndividualFormModel(churchName: churchName, level: level ?? 0, onSubmit: onSubmit);
// 	  case MarksFormKind.mohobenGroup:
// 		return MohobenGroupFormModel(churchName: churchName, level: level ?? 0, onSubmit: onSubmit);
// 	}
//   }
// }
