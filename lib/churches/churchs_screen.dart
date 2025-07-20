import 'package:flutter/material.dart';
import 'package:t7kem_al7an/marks_forms/kg1.dart';
import 'package:t7kem_al7an/marks_forms/mohoben_group.dart';
import 'package:t7kem_al7an/marks_forms/mohoben_individual.dart';

import '../marks_forms/kg2.dart';
import '../marks_forms/talta1.dart';
import '../marks_forms/talta2.dart';

class ChurchesScreen extends StatelessWidget {
  const ChurchesScreen({super.key, required this.data});
  final List<MapEntry<String, String>> data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الكنائس'),
        centerTitle: true,
        backgroundColor: Colors.white70,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemBuilder: (context, i) {
              String level = data.elementAt(i).value;
              String church = data.elementAt(i).key;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                InkWell(
                  child: Card(
                    color: Colors.white60,
                    child: SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            church,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            level == "kg1"
                                ? "مرحلة حضانة المستوى الاول"
                                : level == "kg2"
                                ? "مرحلة حضانة المستوى الثانى"
                                : level == "kgF"
                                ? "موهوبين فردى مرحلة حضانة"
                                : level == "kgG"
                                ? "موهوبين جماعى مرحلة حضانة"
                                : level == "ola1"
                                ? "مرحلة اولى وتانية المستوى الاول"
                                : level == "ola2"
                                ? "مرحلة اولى وتانية المستوى الثانى"
                                : level == "olaF"
                                ? "موهوبين فردى مرحلة اولي وتانية"
                                : level == "olaG"
                                ? "موهوبين جماعى مرحلة اولي وتانية"
                                : level == "talta1"
                                ? "مرحلة تالتة ورابعة المستوى الاول"
                                : level == "talta2"
                                ? "مرحلة تالتة ورابعة المستوى الثانى"
                                : level == "taltaF"
                                ? "موهوبين فردى مرحلة تالتة ورابعة"
                                : level == "taltaG"
                                ? "موهوبين جماعى مرحلة تالتة ورابعة"
                                : level == "khamsa1"
                                ? "مرحلة خامسة وسادسة المستوى الاول"
                                : level == "khamsa2"
                                ? "مرحلة خامسة وسادسة المستوى الثانى"
                                : level == "khamsaF"
                                ? "موهوبين فردى مرحلة خامسة وسادسة"
                                : "موهوبين جماعى مرحلة خامسة وسادسة",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                level == "kg1"
                                    ? Kg1(isKg: true, churchName: church)
                                    : level == "kg2"
                                    ? Kg2(isKg: true, churchName: church)
                                    : level == "kgF"
                                    ? MohobenIndividual(
                                      level: 0,
                                      churchName: church,
                                    )
                                    : level == "kgG"
                                    ? MohobenGroup(
                                      level: 0,
                                      churchName: church,
                                    )
                                    : level == "ola1"
                                    ? Kg1(isKg: false, churchName: church)
                                    : level == "ola2"
                                    ? Kg2(isKg: false, churchName: church)
                                    : level == "olaF"
                                    ? MohobenIndividual(
                                      level: 1,
                                      churchName: church,
                                    )
                                    : level == "olaG"
                                    ? MohobenGroup(
                                      level: 1,
                                      churchName: church,
                                    )
                                    : level == "talta1"
                                    ? Talta1(
                                      isTalta: true,
                                      churchName: church,
                                    )
                                    : level == "talta2"
                                    ? Talta2(
                                      isTalta: true,
                                      churchName: church,
                                    )
                                    : level == "taltaF"
                                    ? MohobenIndividual(
                                      level: 2,
                                      churchName: church,
                                    )
                                    : level == "taltaG"
                                    ? MohobenGroup(
                                      level: 2,
                                      churchName: church,
                                    )
                                    : level == "khamsa1"
                                    ? Talta1(
                                      isTalta: false,
                                      churchName: church,
                                    )
                                    : level == "khamsa2"
                                    ? Talta2(
                                      isTalta: false,
                                      churchName: church,
                                    )
                                    : level == "khamsaF"
                                    ? MohobenIndividual(
                                      level: 3,
                                      churchName: church,
                                    )
                                    : MohobenGroup(
                                      level: 3,
                                      churchName: church,
                                    ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
          itemCount: data.length, // Example count of churche
        ),
      ),
    );
  }
}
