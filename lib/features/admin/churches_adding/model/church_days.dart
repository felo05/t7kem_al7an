class ChurchDays {
  static const List<String> availableDays = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الخميس',
    'السبت (النهائي)'
  ];

  // preserved exactly as original, including entries not reachable
  // from availableDays (الأربعاء, الجمعة) — dead mapping, not fixed here
  static const Map<String, String> _arabicToEnglish = {
    'السبت': 'saturday',
    'الأحد': 'sunday',
    'الإثنين': 'monday',
    'الثلاثاء': 'tuesday',
    'الأربعاء': 'wednesday',
    'الخميس': 'thursday',
    'الجمعة': 'friday',
    'السبت (النهائي)': 'final',
  };

  static String toEnglish(String arabicDay) => _arabicToEnglish[arabicDay] ?? 'saturday';
}