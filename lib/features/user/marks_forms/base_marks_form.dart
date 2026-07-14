import 'package:flutter/material.dart' hide Form;
import 'package:cloud_firestore/cloud_firestore.dart';

import '/core/constants/al7an.dart';
import '/core/widgets/marks_form_fields.dart';

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

  /// Sums controller values + gated boolean bonuses across all groups in
  /// [al7anList], and computes the theoretical max achievable in parallel.
  /// - toolGatedBoolBonus: bonus only counted (and only achievable) when
  ///   that group's L7n.hasTools is true (matches the UI, which only shows
  ///   these checkboxes conditionally).
  /// - alwaysBoolBonus: bonus counted regardless of hasTools.
  /// - invertedBoolBonus: bonus awarded when the checkbox is FALSE (e.g. hzat).
  ({double sum, double maxSum}) _scoreGroups({
    required Form al7anList,
    required List<List<TextEditingController>> controllerGroups,
    required List<List<bool>> boolGroups,
    required List<double> fieldLimits,
    Map<int, double> toolGatedBoolBonus = const {},
    Map<int, double> alwaysBoolBonus = const {},
    Map<int, double> invertedBoolBonus = const {},
  }) {
    double sum = 0;
    double maxSum = 0;

    for (var i = 0; i < al7anList.length; i++) {
      final controllers = controllerGroups[i];
      for (var j = 0; j < controllers.length; j++) {
        sum += _parseDouble(controllers[j].text);
        maxSum += fieldLimits[j];
      }

      final bools = boolGroups[i];
      if (al7anList[i].hasTools) {
        toolGatedBoolBonus.forEach((idx, bonus) {
          sum += bools[idx] ? bonus : 0;
          maxSum += bonus;
        });
      }
      alwaysBoolBonus.forEach((idx, bonus) {
        sum += bools[idx] ? bonus : 0;
        maxSum += bonus;
      });
      invertedBoolBonus.forEach((idx, bonus) {
        sum += !bools[idx] ? bonus : 0;
        maxSum += bonus;
      });
    }

    return (sum: sum, maxSum: maxSum);
  }

  /// Band-based multiplier used by the Mohoben* classes.
  double _bandFactor(double s) {
    if (s >= 50 && s <= 53) return 1.01;
    if (s >= 54 && s <= 56) return 1.02;
    if (s >= 57 && s <= 59) return 1.05;
    if (s >= 60 && s <= 61) return 1.07;
    return 1.0;
  }

  /// Finds max((lastGroupScore + otherGroupsMaxScore) * factor(lastGroupScore))
  /// by checking the finite set of points where the maximum can occur:
  /// each band's right edge (since factor is constant within a band and the
  /// product is increasing in lastGroupScore there) plus the absolute max.
  double _maxFactoredSum({
    required double maxLastGroupScore,
    required double otherGroupsMaxScore,
  }) {
    final candidates = <double>[
      maxLastGroupScore,
      ...[53.0, 56.0, 59.0, 61.0].where((edge) => edge <= maxLastGroupScore),
    ];
    double best = 0;
    for (final s in candidates) {
      final total = (s + otherGroupsMaxScore) * _bandFactor(s);
      if (total > best) best = total;
    }
    return best;
  }
}

class Kg1FormModel extends BaseMarksFormModel {
  Kg1FormModel({
    required super.churchName,
    required super.levelInArabic,
    bool isKg = true,
    Form? al7anList,
    List<List<TextEditingController>>? controllerGroups,
    List<List<bool>>? boolGroups,
    TextEditingController? totalController,
    TextEditingController? slokController,
  })  : isKg = isKg,
        al7anList = al7anList ?? (isKg ? Al7an.kg1 : Al7an.ola1),
        controllerGroups = controllerGroups ??
            List.generate(
              (al7anList ?? (isKg ? Al7an.kg1 : Al7an.ola1)).length,
                  (_) => List.generate(3, (_) => TextEditingController()),
            ),
        boolGroups = boolGroups ??
            List.generate(
              (al7anList ?? (isKg ? Al7an.kg1 : Al7an.ola1)).length,
                  (_) => List.generate(2, (_) => false),
            ),
        totalController = totalController ?? TextEditingController(),
        slokController = slokController ?? TextEditingController(text: '10');

  final bool isKg;
  final Form al7anList;
  final List<List<TextEditingController>> controllerGroups;
  final List<List<bool>> boolGroups;
  final TextEditingController totalController;
  final TextEditingController slokController;

  static const List<double> _fieldLimits = [20.0, 10.0, 10.0];
  static const Map<int, double> _toolGatedBonus = {0: .5, 1: .5}; // df, treanto

  @override
  Widget view() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _churchHeader(),
            _sectionGap(),
            for (var i = 0; i < al7anList.length; i++) ...[
              MarksFormFields.kgForm(
                al7anList[i],
                controllerGroups[i],
                boolGroups[i],
                    (index, value) => setState(() => boolGroups[i][index] = value ?? false),
              ),
              _sectionGap(),
            ],
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
    if (totalController.text.trim().isEmpty || slokController.text.trim().isEmpty) {
      return false;
    }
    if (!_withinRange(slokController.text, 10)) return false;
    for (final group in controllerGroups) {
      if (_isEmptyControllers(group)) return false;
      for (var j = 0; j < group.length; j++) {
        if (!_withinRange(group[j].text, _fieldLimits[j])) return false;
      }
    }
    return true;
  }

  @override
  Map<String, dynamic> buildPayload(String judgeName) {
    final slok = _parseDouble(slokController.text);
    final scored = _scoreGroups(
      al7anList: al7anList,
      controllerGroups: controllerGroups,
      boolGroups: boolGroups,
      fieldLimits: _fieldLimits,
      toolGatedBoolBonus: _toolGatedBonus,
    );

    final sum = scored.sum + slok;

    final payload = <String, dynamic>{};
    for (var i = 0; i < al7anList.length; i++) {
      final group = controllerGroups[i];
      final categoryPayload = <String, dynamic>{
        Al7an.tslem: group[0].text,
        Al7an.tempo: group[1].text,
        Al7an.ro7ania: group[2].text,
      };
      if (al7anList[i].hasTools) {
        categoryPayload[Al7an.df] = boolGroups[i][0];
        categoryPayload[Al7an.treanto] = boolGroups[i][1];
      }
      payload[al7anList[i].name] = categoryPayload;
    }

    payload.addAll({
      'churchName': churchName,
      'kidsTotal': totalController.text,
      'judge': judgeName,
      'slok': slok,
      'total': sum,
      'percent': sum / (scored.maxSum + 10),
    });
    return payload;
  }

  @override
  void dispose() {
    for (final group in controllerGroups) {
      for (final c in group) {
        c.dispose();
      }
    }
    totalController.dispose();
    slokController.dispose();
  }

  @override
  Future<bool> submit(String judgeName) async {
    try {
      final payload = buildPayload(judgeName);
      await FirebaseFirestore.instance
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
      controllerGroups: List.generate(
        al7anList.length,
            (i) => _controllersForCategory(
            data, al7anList[i].name, [Al7an.tslem, Al7an.tempo, Al7an.ro7ania]),
      ),
      boolGroups: List.generate(
        al7anList.length,
            (i) => _boolsForCategory(data, al7anList[i].name, [Al7an.df, Al7an.treanto]),
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
    Form? al7anList,
    List<List<TextEditingController>>? controllerGroups,
    List<List<bool>>? boolGroups,
    TextEditingController? totalController,
    TextEditingController? slokController,
  })  : isKg = isKg,
        al7anList = al7anList ?? (isKg ? Al7an.kg2 : Al7an.ola2),
        controllerGroups = controllerGroups ??
            List.generate(
              (al7anList ?? (isKg ? Al7an.kg2 : Al7an.ola2)).length,
                  (_) => List.generate(3, (_) => TextEditingController()),
            ),
        boolGroups = boolGroups ??
            List.generate(
              (al7anList ?? (isKg ? Al7an.kg2 : Al7an.ola2)).length,
                  (_) => List.generate(2, (_) => false),
            ),
        totalController = totalController ?? TextEditingController(),
        slokController = slokController ?? TextEditingController(text: '10');

  final bool isKg;
  final Form al7anList;
  final List<List<TextEditingController>> controllerGroups;
  final List<List<bool>> boolGroups;
  final TextEditingController totalController;
  final TextEditingController slokController;

  static const List<double> _fieldLimits = [20.0, 10.0, 10.0];
  static const Map<int, double> _toolGatedBonus = {0: .5, 1: .5};

  @override
  Widget view() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _churchHeader(),
            _sectionGap(),
            for (var i = 0; i < al7anList.length; i++) ...[
              MarksFormFields.kgForm(
                al7anList[i],
                controllerGroups[i],
                boolGroups[i],
                    (index, value) => setState(() => boolGroups[i][index] = value ?? false),
              ),
              _sectionGap(),
            ],
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
    if (totalController.text.trim().isEmpty || slokController.text.trim().isEmpty) {
      return false;
    }
    if (!_withinRange(slokController.text, 10)) return false;
    for (final group in controllerGroups) {
      if (_isEmptyControllers(group)) return false;
      for (var j = 0; j < group.length; j++) {
        if (!_withinRange(group[j].text, _fieldLimits[j])) return false;
      }
    }
    return true;
  }

  @override
  Map<String, dynamic> buildPayload(String judgeName) {
    final slok = _parseDouble(slokController.text);
    final scored = _scoreGroups(
      al7anList: al7anList,
      controllerGroups: controllerGroups,
      boolGroups: boolGroups,
      fieldLimits: _fieldLimits,
      toolGatedBoolBonus: _toolGatedBonus,
    );

    final sum = scored.sum + slok;

    final payload = <String, dynamic>{};
    for (var i = 0; i < al7anList.length; i++) {
      final group = controllerGroups[i];
      final categoryPayload = <String, dynamic>{
        Al7an.tslem: group[0].text,
        Al7an.tempo: group[1].text,
        Al7an.ro7ania: group[2].text,
      };
      if (al7anList[i].hasTools) {
        categoryPayload[Al7an.df] = boolGroups[i][0];
        categoryPayload[Al7an.treanto] = boolGroups[i][1];
      }
      payload[al7anList[i].name] = categoryPayload;
    }

    payload.addAll({
      'churchName': churchName,
      'kidsTotal': totalController.text,
      'judge': judgeName,
      'slok': slok,
      'total': sum,
      'percent': sum / (scored.maxSum + 10),
    });
    return payload;
  }

  @override
  void dispose() {
    for (final group in controllerGroups) {
      for (final c in group) {
        c.dispose();
      }
    }
    totalController.dispose();
    slokController.dispose();
  }

  @override
  Future<bool> submit(String judgeName) async {
    final payload = buildPayload(judgeName);
    await FirebaseFirestore.instance
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
      controllerGroups: List.generate(
        al7anList.length,
            (i) => _controllersForCategory(
            data, al7anList[i].name, [Al7an.tslem, Al7an.tempo, Al7an.ro7ania]),
      ),
      boolGroups: List.generate(
        al7anList.length,
            (i) => _boolsForCategory(data, al7anList[i].name, [Al7an.df, Al7an.treanto]),
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
    Form? al7anList,
    List<List<TextEditingController>>? controllerGroups,
    List<List<bool>>? boolGroups,
    TextEditingController? totalController,
    TextEditingController? copticReadingController,
    TextEditingController? taksController,
    TextEditingController? slokController,
  })  : isTalta = isTalta,
        al7anList = al7anList ?? (isTalta ? Al7an.talta1 : Al7an.khamsa1),
        controllerGroups = controllerGroups ??
            List.generate(
              (al7anList ?? (isTalta ? Al7an.talta1 : Al7an.khamsa1)).length,
                  (_) => List.generate(4, (_) => TextEditingController()),
            ),
        boolGroups = boolGroups ??
            List.generate(
              (al7anList ?? (isTalta ? Al7an.talta1 : Al7an.khamsa1)).length,
                  (_) => List.generate(3, (_) => false),
            ),
        totalController = totalController ?? TextEditingController(),
        copticReadingController = copticReadingController ?? TextEditingController(),
        taksController = taksController ?? TextEditingController(),
        slokController = slokController ?? TextEditingController(text: '10');

  final bool isTalta;
  final Form al7anList;
  final List<List<TextEditingController>> controllerGroups;
  final List<List<bool>> boolGroups;
  final TextEditingController totalController;
  final TextEditingController copticReadingController;
  final TextEditingController taksController;
  final TextEditingController slokController;
  double get _taksMax => al7anList.length.toDouble();

  static const List<double> _fieldLimits = [20.0, 10.0, 10.0, 10.0];
  static const Map<int, double> _toolGatedBonus = {0: .5, 1: .5}; // df, treanto
  static const Map<int, double> _invertedBonus = {2: 1.0}; // hzat, always applies

  @override
  Widget view() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _churchHeader(),
            _sectionGap(),
            for (var i = 0; i < al7anList.length; i++) ...[
              MarksFormFields.taltaForm(
                al7anList[i],
                controllerGroups[i],
                boolGroups[i],
                    (index, value) => setState(() => boolGroups[i][index] = value ?? false),
              ),
              _sectionGap(),
            ],
            MarksFormFields.taks(context, taksController, al7anList.length, pdfUrl: al7anList.taksUrl),
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
      for (final group in controllerGroups) ...group,
      taksController,
      copticReadingController,
      totalController,
      slokController,
    ];
    if (requiredControllers.any((c) => c.text.trim().isEmpty)) return false;
    if (!_withinRange(copticReadingController.text, 5)) return false;
    if (!_withinRange(taksController.text, _taksMax)) return false;
    if (!_withinRange(slokController.text, 10)) return false;

    for (final group in controllerGroups) {
      for (var i = 0; i < group.length; i++) {
        if (!_withinRange(group[i].text, _fieldLimits[i])) return false;
      }
    }
    return true;
  }

  @override
  Map<String, dynamic> buildPayload(String judgeName) {
    final slok = _parseDouble(slokController.text);
    final taks = _parseDouble(taksController.text);
    final copticReading = _parseDouble(copticReadingController.text);

    final scored = _scoreGroups(
      al7anList: al7anList,
      controllerGroups: controllerGroups,
      boolGroups: boolGroups,
      fieldLimits: _fieldLimits,
      toolGatedBoolBonus: _toolGatedBonus,
      invertedBoolBonus: _invertedBonus,
    );

    final sum = scored.sum + slok + taks + copticReading;

    final payload = <String, dynamic>{};
    for (var i = 0; i < al7anList.length; i++) {
      final group = controllerGroups[i];
      payload[al7anList[i].name] = {
        Al7an.tslem: group[0].text,
        Al7an.tempo: group[1].text,
        Al7an.ro7ania: group[2].text,
        Al7an.copticSpelling: group[3].text,
        if (al7anList[i].hasTools) Al7an.df: boolGroups[i][0],
        if (al7anList[i].hasTools) Al7an.treanto: boolGroups[i][1],
        Al7an.hzat: boolGroups[i][2],
      };
    }

    payload.addAll({
      'churchName': churchName,
      'kidsTotal': totalController.text,
      'judge': judgeName,
      'slok': slok,
      'taks': taks,
      'copticReading': copticReading,
      'total': sum,
      'percent': sum / (scored.maxSum + 10 + 4 + 5),
    });
    return payload;
  }

  @override
  void dispose() {
    for (final group in controllerGroups) {
      for (final c in group) {
        c.dispose();
      }
    }
    totalController.dispose();
    copticReadingController.dispose();
    taksController.dispose();
    slokController.dispose();
  }

  @override
  Future<bool> submit(String judgeName) async {
    final payload = buildPayload(judgeName);
    await FirebaseFirestore.instance
        .collection(isTalta ? "taltaRaba1ResultsFinal" : "khamsaSadsa1ResultsFinal")
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
      controllerGroups: List.generate(
        al7anList.length,
            (i) => _controllersForCategory(data, al7anList[i].name,
            [Al7an.tslem, Al7an.tempo, Al7an.ro7ania, Al7an.copticSpelling]),
      ),
      boolGroups: List.generate(
        al7anList.length,
            (i) => _boolsForCategory(data, al7anList[i].name, [Al7an.df, Al7an.treanto, Al7an.hzat]),
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
    Form? al7anList,
    List<List<TextEditingController>>? controllerGroups,
    List<List<bool>>? boolGroups,
    TextEditingController? totalController,
    TextEditingController? copticReadingController,
    TextEditingController? taksController,
    TextEditingController? slokController,
  })  : isTalta = isTalta,
        al7anList = al7anList ?? (isTalta ? Al7an.talta2 : Al7an.khamsa2),
        controllerGroups = controllerGroups ??
            List.generate(
              (al7anList ?? (isTalta ? Al7an.talta2 : Al7an.khamsa2)).length,
                  (_) => List.generate(4, (_) => TextEditingController()),
            ),
        boolGroups = boolGroups ??
            List.generate(
              (al7anList ?? (isTalta ? Al7an.talta2 : Al7an.khamsa2)).length,
                  (_) => List.generate(3, (_) => false),
            ),
        totalController = totalController ?? TextEditingController(),
        copticReadingController = copticReadingController ?? TextEditingController(),
        taksController = taksController ?? TextEditingController(),
        slokController = slokController ?? TextEditingController(text: '10');

  final bool isTalta;
  final Form al7anList;
  final List<List<TextEditingController>> controllerGroups;
  final List<List<bool>> boolGroups;
  final TextEditingController totalController;
  final TextEditingController copticReadingController;
  final TextEditingController taksController;
  final TextEditingController slokController;

  static const List<double> _fieldLimits = [20.0, 10.0, 10.0, 10.0];
  static const Map<int, double> _toolGatedBonus = {0: .5, 1: .5};
  static const Map<int, double> _invertedBonus = {2: 1.0};
  static const double _copticReadingMax = 10.0;

  double get _taksMax => al7anList.length.toDouble();

  @override
  Widget view() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _churchHeader(),
            _sectionGap(),
            for (var i = 0; i < al7anList.length; i++) ...[
              MarksFormFields.taltaForm(
                al7anList[i],
                controllerGroups[i],
                boolGroups[i],
                    (index, value) => setState(() => boolGroups[i][index] = value ?? false),
              ),
              _sectionGap(),
            ],
            MarksFormFields.taks(context, taksController, al7anList.length, pdfUrl: al7anList.taksUrl),
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
      for (final group in controllerGroups) ...group,
      taksController,
      copticReadingController,
      totalController,
      slokController,
    ];
    if (requiredControllers.any((c) => c.text.trim().isEmpty)) return false;
    if (!_withinRange(copticReadingController.text, _copticReadingMax)) return false;
    if (!_withinRange(taksController.text, _taksMax)) return false;
    if (!_withinRange(slokController.text, 10)) return false;

    for (final group in controllerGroups) {
      for (var i = 0; i < group.length; i++) {
        if (!_withinRange(group[i].text, _fieldLimits[i])) return false;
      }
    }
    return true;
  }

  @override
  Map<String, dynamic> buildPayload(String judgeName) {
    final slok = _parseDouble(slokController.text);
    final taks = _parseDouble(taksController.text);
    final copticReading = _parseDouble(copticReadingController.text);

    final scored = _scoreGroups(
      al7anList: al7anList,
      controllerGroups: controllerGroups,
      boolGroups: boolGroups,
      fieldLimits: _fieldLimits,
      toolGatedBoolBonus: _toolGatedBonus,
      invertedBoolBonus: _invertedBonus,
    );

    final sum = scored.sum + slok + taks + copticReading;

    final payload = <String, dynamic>{};
    for (var i = 0; i < al7anList.length; i++) {
      final group = controllerGroups[i];
      payload[al7anList[i].name] = {
        Al7an.tslem: group[0].text,
        Al7an.tempo: group[1].text,
        Al7an.ro7ania: group[2].text,
        Al7an.copticSpelling: group[3].text,
        if (al7anList[i].hasTools) Al7an.df: boolGroups[i][0],
        if (al7anList[i].hasTools) Al7an.treanto: boolGroups[i][1],
        Al7an.hzat: boolGroups[i][2],
      };
    }

    payload.addAll({
      'churchName': churchName,
      'kidsTotal': totalController.text,
      'judge': judgeName,
      'slok': slok,
      'taks': taks,
      'copticReading': copticReading,
      'total': sum,
      'percent': sum / (scored.maxSum + 10 + _taksMax + _copticReadingMax),
    });
    return payload;
  }

  @override
  void dispose() {
    for (final group in controllerGroups) {
      for (final c in group) {
        c.dispose();
      }
    }
    totalController.dispose();
    copticReadingController.dispose();
    taksController.dispose();
    slokController.dispose();
  }

  @override
  Future<bool> submit(String judgeName) async {
    final payload = buildPayload(judgeName);
    await FirebaseFirestore.instance
        .collection(isTalta ? "taltaRaba2ResultsFinal" : "khamsaSadsa2ResultsFinal")
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
      controllerGroups: List.generate(
        al7anList.length,
            (i) => _controllersForCategory(data, al7anList[i].name,
            [Al7an.tslem, Al7an.tempo, Al7an.ro7ania, Al7an.copticSpelling]),
      ),
      boolGroups: List.generate(
        al7anList.length,
            (i) => _boolsForCategory(data, al7anList[i].name, [Al7an.df, Al7an.treanto, Al7an.hzat]),
      ),
      totalController: _textControllerFrom(data['kidsTotal']),
      copticReadingController: _textControllerFrom(data['copticReading']),
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
    Form? al7anList,
    List<List<TextEditingController>>? controllerGroups,
    List<List<bool>>? boolGroups,
    TextEditingController? taksController,
  })  : al7anList = al7anList ?? _formForLevel(level),
        controllerGroups = controllerGroups ??
            List.generate(
              (al7anList ?? _formForLevel(level)).length,
                  (_) => List.generate(3, (_) => TextEditingController()),
            ),
        boolGroups = boolGroups ??
            List.generate(
              (al7anList ?? _formForLevel(level)).length,
                  (_) => List.generate(1, (_) => false),
            ),
        taksController = taksController ?? TextEditingController();

  final int level;
  final Form al7anList;
  final List<List<TextEditingController>> controllerGroups;
  final List<List<bool>> boolGroups;
  final TextEditingController taksController;

  static const List<double> _fieldLimits = [15.0, 10.0, 10.0];
  static const int _dfIdx = 0;

  double get _taksMax => al7anList.length.toDouble();

  static Form _formForLevel(int level) => level == 0
      ? Al7an.kg3
      : level == 1
      ? Al7an.ola3
      : level == 2
      ? Al7an.talta3
      : Al7an.khamsa3;

  @override
  Widget view() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _churchHeader(),
            _sectionGap(),
            for (var i = 0; i < al7anList.length; i++) ...[
              MarksFormFields.mohobenIndividualForm(
                al7anList[i],
                controllerGroups[i],
                boolGroups[i],
                    (index, value) => setState(() => boolGroups[i][index] = value ?? false),
                level,
              ),
              _sectionGap(),
            ],
            MarksFormFields.taks(context, taksController, al7anList.length, pdfUrl: al7anList.taksUrl),
          ],
        );
      },
    );
  }

  @override
  bool validate() {
    if (taksController.text.trim().isEmpty) return false;
    if (!_withinRange(taksController.text, _taksMax)) return false;
    for (final group in controllerGroups) {
      if (_isEmptyControllers(group)) return false;
      for (var i = 0; i < group.length; i++) {
        if (!_withinRange(group[i].text, _fieldLimits[i])) return false;
      }
    }
    return true;
  }

  double _groupScore(int i) {
    double s = 0;
    for (final c in controllerGroups[i]) {
      s += _parseDouble(c.text);
    }
    if (al7anList[i].hasTools) s += boolGroups[i][_dfIdx] ? 1 : 0;
    return s;
  }

  double _groupMax(int i) {
    double m = _fieldLimits.reduce((a, b) => a + b);
    if (al7anList[i].hasTools) m += 1; // df
    return m;
  }

  @override
  Map<String, dynamic> buildPayload(String judgeName) {
    final taks = _parseDouble(taksController.text);
    final lastIndex = al7anList.length - 1;

    double sum = _groupScore(lastIndex); // factor threshold determined by last group
    final factor = _bandFactor(sum);

    for (var i = 0; i < lastIndex; i++) {
      sum += _groupScore(i);
    }
    sum += taks;
    sum *= factor;

    double otherGroupsMax = 0;
    for (var i = 0; i < lastIndex; i++) {
      otherGroupsMax += _groupMax(i);
    }
    final maxSum = _maxFactoredSum(
      maxLastGroupScore: _groupMax(lastIndex),
      otherGroupsMaxScore: otherGroupsMax + _taksMax,
    );

    final payload = <String, dynamic>{};
    for (var i = 0; i < al7anList.length; i++) {
      final group = controllerGroups[i];
      payload[al7anList[i].name] = {
        Al7an.tslem: group[0].text,
        Al7an.copticReading: group[1].text,
        Al7an.ro7ania: group[2].text,
        if (al7anList[i].hasTools) Al7an.df: boolGroups[i][_dfIdx],
      };
    }

    payload.addAll({
      'churchName': churchName,
      'judge': judgeName,
      'taks': taks,
      'total': sum,
      'percent': sum / maxSum,
    });
    return payload;
  }

  @override
  void dispose() {
    for (final group in controllerGroups) {
      for (final c in group) {
        c.dispose();
      }
    }
    taksController.dispose();
  }

  @override
  Future<bool> submit(String judgeName) async {
    final payload = buildPayload(judgeName);
    await FirebaseFirestore.instance
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
    final al7anList = _formForLevel(level);
    return MohobenIndividualFormModel(
      churchName: data['churchName']?.toString(),
      levelInArabic: levelInArabic,
      level: level,
      al7anList: al7anList,
      controllerGroups: List.generate(
        al7anList.length,
            (i) => _controllersForCategory(
            data, al7anList[i].name, [Al7an.tslem, Al7an.copticReading, Al7an.ro7ania]),
      ),
      boolGroups: List.generate(
        al7anList.length,
            (i) => _boolsForCategory(data, al7anList[i].name, [Al7an.df]),
      ),
      taksController: _textControllerFrom(data['taks']),
    );
  }
}

class MohobenGroupFormModel extends BaseMarksFormModel {
  MohobenGroupFormModel({
    required super.churchName,
    required super.levelInArabic,
    required this.level,
    Form? al7anList,
    List<List<TextEditingController>>? controllerGroups,
    List<List<bool>>? boolGroups,
    TextEditingController? totalController,
    TextEditingController? slokController,
    TextEditingController? taksController,
  })  : al7anList = al7anList ?? _formForLevel(level),
        controllerGroups = controllerGroups ??
            List.generate(
              (al7anList ?? _formForLevel(level)).length,
                  (_) => List.generate(5, (_) => TextEditingController()),
            ),
        boolGroups = boolGroups ??
            List.generate(
              (al7anList ?? _formForLevel(level)).length,
                  (_) => List.generate(2, (_) => false),
            ),
        totalController = totalController ?? TextEditingController(),
        slokController = slokController ?? TextEditingController(text: '10'),
        taksController = taksController ?? TextEditingController();

  final int level;
  final Form al7anList;
  final List<List<TextEditingController>> controllerGroups;
  final List<List<bool>> boolGroups;
  final TextEditingController totalController;
  final TextEditingController slokController;
  final TextEditingController taksController;

  static const List<double> _fieldLimits = [20.0, 10.0, 10.0, 10.0, 10.0];
  static const int _dfIdx = 0;
  static const int _treantoIdx = 1;

  double get _taksMax => al7anList.length.toDouble();

  static Form _formForLevel(int level) => level == 0
      ? Al7an.kg3
      : level == 1
      ? Al7an.ola3
      : level == 2
      ? Al7an.talta3
      : Al7an.khamsa3;

  @override
  Widget view() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _churchHeader(),
            _sectionGap(),
            for (var i = 0; i < al7anList.length; i++) ...[
              MarksFormFields.mohobenGroupForm(
                al7anList[i],
                controllerGroups[i],
                boolGroups[i],
                    (index, value) => setState(() => boolGroups[i][index] = value ?? false),
                level,
              ),
              _sectionGap(20),
            ],
            MarksFormFields.taks(context, taksController, al7anList.length, pdfUrl: al7anList.taksUrl),
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
        slokController.text.trim().isEmpty ||
        taksController.text.trim().isEmpty) {
      return false;
    }
    if (!_withinRange(slokController.text, 10)) return false;
    if (!_withinRange(taksController.text, _taksMax)) return false;
    for (final group in controllerGroups) {
      if (_isEmptyControllers(group)) return false;
      for (var i = 0; i < group.length; i++) {
        if (!_withinRange(group[i].text, _fieldLimits[i])) return false;
      }
    }
    return true;
  }

  double _groupScore(int i) {
    double s = 0;
    for (final c in controllerGroups[i]) {
      s += _parseDouble(c.text);
    }
    if (al7anList[i].hasTools) {
      s += boolGroups[i][_dfIdx] ? .5 : 0;
      s += boolGroups[i][_treantoIdx] ? .5 : 0;
    }
    return s;
  }

  double _groupMax(int i) {
    double m = _fieldLimits.reduce((a, b) => a + b);
    if (al7anList[i].hasTools) m += 1; // df(.5) + treanto(.5)
    return m;
  }

  @override
  Map<String, dynamic> buildPayload(String judgeName) {
    final slok = _parseDouble(slokController.text);
    final taks = _parseDouble(taksController.text);
    final lastIndex = al7anList.length - 1;

    double sum = _groupScore(lastIndex); // factor threshold determined by last group
    final factor = _bandFactor(sum);

    for (var i = 0; i < lastIndex; i++) {
      sum += _groupScore(i);
    }
    sum += taks;
    sum *= factor;
    sum += slok; // slok added AFTER multiplier, matching original behavior

    double otherGroupsMax = 0;
    for (var i = 0; i < lastIndex; i++) {
      otherGroupsMax += _groupMax(i);
    }
    final maxSum = _maxFactoredSum(
      maxLastGroupScore: _groupMax(lastIndex),
      otherGroupsMaxScore: otherGroupsMax + _taksMax,
    ) +
        10; // slok max, added post-multiplication like above

    final payload = <String, dynamic>{};
    for (var i = 0; i < al7anList.length; i++) {
      final group = controllerGroups[i];
      payload[al7anList[i].name] = {
        Al7an.tslem: group[0].text,
        Al7an.tempo: group[1].text,
        Al7an.tnas2: group[2].text,
        Al7an.copticReading: group[3].text,
        Al7an.ro7ania: group[4].text,
        if (al7anList[i].hasTools) Al7an.df: boolGroups[i][_dfIdx],
        if (al7anList[i].hasTools) Al7an.treanto: boolGroups[i][_treantoIdx],
      };
    }

    payload.addAll({
      'churchName': churchName,
      'kidsTotal': totalController.text,
      'judge': judgeName,
      'slok': slok,
      'taks': taks,
      'total': sum,
      'percent': sum / maxSum,
    });
    return payload;
  }

  @override
  void dispose() {
    for (final group in controllerGroups) {
      for (final c in group) {
        c.dispose();
      }
    }
    totalController.dispose();
    slokController.dispose();
    taksController.dispose();
  }

  @override
  Future<bool> submit(String judgeName) async {
    final payload = buildPayload(judgeName);
    await FirebaseFirestore.instance
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
    final al7anList = _formForLevel(level);
    return MohobenGroupFormModel(
      churchName: data['churchName']?.toString(),
      levelInArabic: levelInArabic,
      level: level,
      al7anList: al7anList,
      controllerGroups: List.generate(
        al7anList.length,
            (i) => _controllersForCategory(data, al7anList[i].name,
            [Al7an.tslem, Al7an.tempo, Al7an.tnas2, Al7an.copticReading, Al7an.ro7ania]),
      ),
      boolGroups: List.generate(
        al7anList.length,
            (i) => _boolsForCategory(data, al7anList[i].name, [Al7an.df, Al7an.treanto]),
      ),
      totalController: _textControllerFrom(data['kidsTotal']),
      slokController: _textControllerFrom(data['slok'] ?? 10),
      taksController: _textControllerFrom(data['taks']),
    );
  }
}