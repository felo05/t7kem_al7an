import '../../marks_forms/base_marks_form.dart';

class ChurchLevelsModel {
  static const List<String> days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  static const List<String> levels = [
    "kg1", "kg2", "kgF", "kgG",
    "oulaTanya1", "oulaTanya2", "oulaTanyaF", "oulaTanyaG",
    "taltaRaba1", "taltaRaba2", "taltaRabaF", "taltaRabaG",
    "khamsaSadsa1", "khamsaSadsa2", "khamsaSadsaF", "khamsaSadsaG"
  ];

  static Map<String, BaseMarksFormModel> get levelToForm => {
    'kg1': Kg1FormModel(isKg: true, churchName: "", levelInArabic: "مرحلة حضانة المستوى الاول"),
    'kg2': Kg2FormModel(isKg: true, churchName: "", levelInArabic: "مرحلة حضانة المستوى الثانى"),
    'kgF': MohobenIndividualFormModel(level: 0, churchName: "", levelInArabic: "موهوبين فردى مرحلة حضانة"),
    'kgG': MohobenGroupFormModel(level: 0, churchName: "", levelInArabic: "موهوبين جماعى مرحلة حضانة"),
    'oulaTanya1': Kg1FormModel(isKg: false, churchName: "", levelInArabic: "مرحلة اولى وتانية المستوى الاول"),
    'oulaTanya2': Kg2FormModel(isKg: false, churchName: "", levelInArabic: "مرحلة اولى وتانية المستوى الثانى"),
    'oulaTanyaF': MohobenIndividualFormModel(level: 1, churchName: "", levelInArabic: "موهوبين فردى مرحلة اولى وتانية"),
    'oulaTanyaG': MohobenGroupFormModel(level: 1, churchName: "", levelInArabic: "موهوبين الجماعى مرحلة اولى وتانية"),
    'taltaRaba1': Talta1FormModel(isTalta: true, churchName: "", levelInArabic: "مرحلة ثالثة ورابعة المستوى الاول"),
    'taltaRaba2': Talta2FormModel(isTalta: true, churchName: "", levelInArabic: "مرحلة الثالثة ورابعة المستوى الثانى"),
    'taltaRabaF': MohobenIndividualFormModel(level: 2, churchName: "", levelInArabic: "موهوبين فردى مرحلة ثالثة ورابعة"),
    'taltaRabaG': MohobenGroupFormModel(level: 2, churchName: "", levelInArabic: "موهوبين الجماعى مرحلة ثالثة ورابعة"),
    'khamsaSadsa1': Talta1FormModel(isTalta: false, churchName: "", levelInArabic: "مرحلة خامسة وسادسة المستوى الاول"),
    'khamsaSadsa2': Talta2FormModel(isTalta: false, churchName: "", levelInArabic: "مرحلة خامسة وسادسة المستوى الثانى"),
    'khamsaSadsaF': MohobenIndividualFormModel(level: 3, churchName: "", levelInArabic: "موهوبين فردى مرحلة خامسة وسادسة"),
    'khamsaSadsaG': MohobenGroupFormModel(level: 3, churchName: "", levelInArabic: "موهوبين الجماعى مرحلة خامسة وسادسة"),
  };

  static String resolveDayName() {
    return DateTime.now().day != 2
        ? days[DateTime.now().weekday - 1].toLowerCase()
        : "final";
  }
}