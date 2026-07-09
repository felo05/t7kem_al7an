class AddChurchFormData {
  AddChurchFormData({
    required this.churchName,
    required this.selectedDayArabic,
    required this.categoryToggles,
    required this.giftedIndividualLists,
  });

  final String churchName;
  final String selectedDayArabic;
  final Map<String, bool> categoryToggles; // e.g. 'kg1' -> true
  final Map<String, List<String>> giftedIndividualLists; // 'kg' -> [names]

  Map<String, dynamic> toChurchesDocument() {
    List<String> cleaned(String key) =>
        (giftedIndividualLists[key] ?? []).where((i) => i.isNotEmpty).toList();

    return {
      'day': selectedDayArabic,
      'churchName': churchName,
      'categories': {
        'nursery': {
          'level1': categoryToggles['kg1'] ?? false,
          'level2': categoryToggles['kg2'] ?? false,
          'giftedGroup': categoryToggles['kgG'] ?? false,
          'giftedIndividual': cleaned('kg'),
        },
        'firstSecond': {
          'level1': categoryToggles['oulaTanya1'] ?? false,
          'level2': categoryToggles['oulaTanya2'] ?? false,
          'giftedGroup': categoryToggles['oulaTanyaG'] ?? false,
          'giftedIndividual': cleaned('oulaTanya'),
        },
        'thirdFourth': {
          'level1': categoryToggles['taltaRaba1'] ?? false,
          'level2': categoryToggles['taltaRaba2'] ?? false,
          'giftedGroup': categoryToggles['taltaRabaG'] ?? false,
          'giftedIndividual': cleaned('taltaRaba'),
        },
        'fifthSixth': {
          'level1': categoryToggles['khamsaSadsa1'] ?? false,
          'level2': categoryToggles['khamsaSadsa2'] ?? false,
          'giftedGroup': categoryToggles['khamsaSadsaG'] ?? false,
          'giftedIndividual': cleaned('khamsaSadsa'),
        },
      },
    };
  }
}