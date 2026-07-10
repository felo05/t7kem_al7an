class AssignJudgeDays {
  static const List<String> availableDays = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الخميس',
    'النهائي'
  ];

  // preserved exactly from original — includes unreachable entries, default 'final'
  static const Map<String, String> _arabicToEnglish = {
    'السبت': 'saturday',
    'الأحد': 'sunday',
    'الإثنين': 'monday',
    'الثلاثاء': 'tuesday',
    'الأربعاء': 'wednesday',
    'الخميس': 'thursday',
    'الجمعة': 'friday',
    'النهائي': 'final',
  };

  static String toEnglish(String arabicDay) =>
      _arabicToEnglish[arabicDay] ?? 'final';
}
