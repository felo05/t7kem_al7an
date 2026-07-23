/// Resolves which physical Firestore collection a level's results should
/// use today: the "*ResultsFinal" collection on the 1st of the month,
/// or the parallel "*Results" (non-final) collection every other day.
class FinalDayGate {
  static bool get isFinalDay => DateTime.now().day == 1;

  /// Pass the canonical "*ResultsFinal" name (as used in
  /// ResultCollections.all / base_marks_form.dart submit() calls) and get
  /// back whichever collection is actually live today.
  static String resolve(String finalCollectionName) {
    final base = finalCollectionName.endsWith('ResultsFinal')
        ? finalCollectionName.substring(
        0, finalCollectionName.length - 'ResultsFinal'.length)
        : finalCollectionName;
    return isFinalDay ? '${base}ResultsFinal' : '${base}Results';
  }
}