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
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                                                  : level == "oulaTanya1"
                                                      ? "مرحلة اولى وتانية المستوى الاول"
                                                      : level == "oulaTanya2"
                                                          ? "مرحلة اولى وتانية المستوى الثانى"
                                                          : level == "oulaTanyaF"
                                                              ? "موهوبين فردى مرحلة اولي وتانية"
                                                              : level == "oulaTanyaG"
                                                                  ? "موهوبين جماعى مرحلة اولي وتانية"
                                                                  : level ==
                                                                          "taltaRaba1"
                                                                      ? "مرحلة تالتة ورابعة المستوى الاول"
                                                                      : level ==
                                                                              "taltaRaba2"
                                                                          ? "مرحلة تالتة ورابعة المستوى الثانى"
                                                                          : level ==
                                                                                  "taltaRabaF"
                                                                              ? "موهوبين فردى مرحلة تالتة ورابعة"
                                                                              : level == "taltaRabaG"
                                                                                  ? "موهوبين جماعى مرحلة تالتة ورابعة"
                                                                                  : level == "khamsaSadsa1"
                                                                                      ? "مرحلة خامسة وسادسة المستوى الاول"
                                                                                      : level == "khamsaSadsa2"
                                                                                          ? "مرحلة خامسة وسادسة المستوى الثانى"
                                                                                          : level == "khamsaSadsaF"
                                                                                              ? "موهوبين فردى مرحلة خامسة وسادسة"
                                                                                              : "موهوبين جماعى مرحلة خامسة وسادسة",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,

                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => level == "kg1"
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
                                              : level == "oulaTanya1"
                                                  ? Kg1(
                                                      isKg: false,
                                                      churchName: church)
                                                  : level == "oulaTanya2"
                                                      ? Kg2(
                                                          isKg: false,
                                                          churchName: church)
                                                      : level == "oulaTanyaF"
                                                          ? MohobenIndividual(
                                                              level: 1,
                                                              churchName: church,
                                                            )
                                                          : level == "oulaTanyaG"
                                                              ? MohobenGroup(
                                                                  level: 1,
                                                                  churchName:
                                                                      church,
                                                                )
                                                              : level == "taltaRaba1"
                                                                  ? Talta1(
                                                                      isTalta: true,
                                                                      churchName:
                                                                          church,
                                                                    )
                                                                  : level ==
                                                                          "taltaRaba2"
                                                                      ? Talta2(
                                                                          isTalta:
                                                                              true,
                                                                          churchName:
                                                                              church,
                                                                        )
                                                                      : level ==
                                                                              "taltaRabaF"
                                                                          ? MohobenIndividual(
                                                                              level:
                                                                                  2,
                                                                              churchName:
                                                                                  church,
                                                                            )
                                                                          : level ==
                                                                                  "taltaRabaG"
                                                                              ? MohobenGroup(
                                                                                  level: 2,
                                                                                  churchName: church,
                                                                                )
                                                                              : level == "khamsaSadsa1"
                                                                                  ? Talta1(
                                                                                      isTalta: false,
                                                                                      churchName: church,
                                                                                    )
                                                                                  : level == "khamsaSadsa2"
                                                                                      ? Talta2(
                                                                                          isTalta: false,
                                                                                          churchName: church,
                                                                                        )
                                                                                      : level == "khamsaSadsaF"
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
