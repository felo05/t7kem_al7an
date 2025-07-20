import 'package:hive_flutter/adapters.dart';

class HiveHelper {
  static String boxKey = "BoxKey";
  static String nameKey = "Name";
  static String churches = "Churches";
  static void init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxKey);
  }

  static void setName(String name) async {
    await Hive.box(boxKey).put(nameKey, name);
  }

  static String? getName() {
    if (Hive.box(boxKey).containsKey(nameKey)) {
      return Hive.box(boxKey).get(nameKey);
    }
    return null;
  }

  static void clearName() async {
    await Hive.box(boxKey).delete(nameKey);
  }

  static void setChurches(List<MapEntry<String, String>> churches) async {
    await Hive.box(boxKey).put(churches, churches);
  }

  static List<MapEntry<String, String>>? getChurches() {
    if (Hive.box(boxKey).containsKey(churches)) {
      return Hive.box(boxKey).get(churches) as List<MapEntry<String, String>>;
    }
    return null;
  }

  static void clearChurches() async {
    await Hive.box(boxKey).delete(churches);
  }
}
