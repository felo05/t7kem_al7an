import 'church_average.dart';
import 'church_result_doc.dart';

class ChurchAverageCalculator {
  /// Matches original CollectionDetailsScreen ranking: every church group
  /// included, average = sum(all percents, zeros count) / documentCount.
  static List<ChurchAverage> computeForRanking(List<ChurchResultDoc> docs) {
    final result = _group(docs).entries.map((entry) {
      final documents = entry.value;
      final totalSum = documents.fold<double>(0, (sum, d) => sum + d.percent);
      return ChurchAverage(
        churchName: entry.key,
        averagePercent: totalSum / documents.length,
        documentCount: documents.length,
        allDocuments: documents,
      );
    }).toList();
    result.sort((a, b) => b.averagePercent.compareTo(a.averagePercent));
    return result;
  }

  /// Matches original PDF top-church selection: only percent > 0 counts,
  /// churches with no valid (>0) results are excluded entirely.
  static List<ChurchAverage> computeValidOnly(List<ChurchResultDoc> docs) {
    final result = <ChurchAverage>[];
    for (final entry in _group(docs).entries) {
      final documents = entry.value;
      double totalSum = 0;
      int validDocs = 0;
      for (final d in documents) {
        if (d.percent > 0) {
          totalSum += d.percent;
          validDocs++;
        }
      }
      if (validDocs > 0) {
        result.add(ChurchAverage(
          churchName: entry.key,
          averagePercent: totalSum / validDocs,
          documentCount: documents.length,
          allDocuments: documents,
        ));
      }
    }
    result.sort((a, b) => b.averagePercent.compareTo(a.averagePercent));
    return result;
  }

  static Map<String, List<ChurchResultDoc>> _group(List<ChurchResultDoc> docs) {
    final groups = <String, List<ChurchResultDoc>>{};
    for (final doc in docs) {
      groups.putIfAbsent(doc.churchName, () => []).add(doc);
    }
    return groups;
  }
}