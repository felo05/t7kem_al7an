import 'package:cloud_firestore/cloud_firestore.dart';

class ChurchResultDoc {
  ChurchResultDoc(
      {required this.id, required this.percent, required this.data});

  final String id;
  final double percent;
  final Map<String, dynamic> data;

  String get churchName =>
      (data['churchName'] ?? data['church'] ?? 'غير محدد').toString();

  factory ChurchResultDoc.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ChurchResultDoc(
      id: doc.id,
      percent: (data['percent'] as num?)?.toDouble() ?? 0,
      data: data,
    );
  }
}
