import 'church_result_doc.dart';

class ChurchAverage {
  ChurchAverage({
    required this.churchName,
    required this.averagePercent,
    required this.documentCount,
    required this.allDocuments,
  });

  final String churchName;
  final double averagePercent;
  final int documentCount;
  final List<ChurchResultDoc> allDocuments;
}