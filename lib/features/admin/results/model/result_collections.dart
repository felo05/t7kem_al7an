import 'package:flutter/material.dart';

class ResultCollections {
  static const List<String> all = [
    'kg1ResultsFinal', 'kg2ResultsFinal', 'kgGResultsFinal', 'kgFResultsFinal',
    'oulaTanya1ResultsFinal', 'oulaTanya2ResultsFinal', 'oulaTanyaGResultsFinal', 'oulaTanyaFResultsFinal',
    'taltaRaba1ResultsFinal', 'taltaRaba2ResultsFinal', 'taltaRabaGResultsFinal', 'taltaRabaFResultsFinal',
    'khamsaSadsa1ResultsFinal', 'khamsaSadsa2ResultsFinal', 'khamsaSadsaGResultsFinal', 'khamsaSadsaFResultsFinal',
  ];

  // NOTE: CheckStatusScreen and ChurchDetailsScreen had slightly different
  // Arabic text for oulaTanyaF/taltaRabaF/khamsaSadsaF ("موهوبين فردي" vs
  // "موهوبين الفردي" — extra "ال"). Centralizing forced picking one; I kept
  // CheckStatusScreen's version. Flag if the other was intentional.
  static String displayName(String collection) {
    final name = collection.replaceAll('ResultsFinal', '');
    switch (name) {
      case 'kg1': return 'حضانة المستوى الأول';
      case 'kg2': return 'حضانة المستوى الثاني';
      case 'kgG': return 'حضانة موهوبين جماعي';
      case 'kgF': return 'حضانة موهوبين فردي';
      case 'oulaTanya1': return 'أولى وثانية المستوى الأول';
      case 'oulaTanya2': return 'أولى وثانية المستوى الثاني';
      case 'oulaTanyaG': return 'أولى وثانية موهوبين جماعي';
      case 'oulaTanyaF': return 'أولى وثانية موهوبين فردي';
      case 'taltaRaba1': return 'ثالثة ورابعة المستوى الأول';
      case 'taltaRaba2': return 'ثالثة ورابعة المستوى الثاني';
      case 'taltaRabaG': return 'ثالثة ورابعة موهوبين جماعي';
      case 'taltaRabaF': return 'ثالثة ورابعة موهوبين فردي';
      case 'khamsaSadsa1': return 'خامسة وسادسة المستوى الأول';
      case 'khamsaSadsa2': return 'خامسة وسادسة المستوى الثاني';
      case 'khamsaSadsaG': return 'خامسة وسادسة موهوبين جماعي';
      case 'khamsaSadsaF': return 'خامسة وسادسة موهوبين فردي';
      default: return name;
    }
  }

  static IconData icon(String collection) {
    if (collection.contains('kg')) return Icons.child_care;
    if (collection.contains('oulaTanya')) return Icons.school;
    if (collection.contains('taltaRaba')) return Icons.menu_book;
    if (collection.contains('khamsaSadsa')) return Icons.auto_stories;
    return Icons.emoji_events;
  }

  static Color color(String collection) {
    if (collection.contains('kg')) return Colors.green;
    if (collection.contains('oulaTanya')) return Colors.blue;
    if (collection.contains('taltaRaba')) return Colors.orange;
    if (collection.contains('khamsaSadsa')) return Colors.purple;
    return Colors.grey;
  }
}