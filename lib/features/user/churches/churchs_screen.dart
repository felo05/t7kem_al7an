import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/features/user/churches/cubit/churches_cubit.dart';
import 'package:t7kem_al7an/features/user/marks_forms/base_marks_form.dart';
import 'package:t7kem_al7an/features/user/marks_forms/form_screen.dart';

import '../../authentication/user.dart';

class ChurchesScreen extends StatelessWidget {
  const ChurchesScreen({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChurchesCubit(),
      child: _ChurchesBody(user: user),
    );
  }
}

class _ChurchesBody extends StatefulWidget {
  const _ChurchesBody({required this.user});
  final User user;

  @override
  State<_ChurchesBody> createState() => _ChurchesBodyState();
}

class _ChurchesBodyState extends State<_ChurchesBody> {
  late final Stream<List<BaseMarksFormModel>> _churchesStream;

  @override
  void initState() {
    super.initState();
    _churchesStream = context.read<ChurchesCubit>().watchChurches(widget.user);
  }

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
        child: StreamBuilder<List<BaseMarksFormModel>>(
          stream: _churchesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('حصلت مشكلة جرب تاني'));
            }

            final churches = snapshot.data ?? [];
            if (churches.isEmpty) {
              return ListView(children: const [
                SizedBox(height: 250),
                Center(
                  child: Text(
                    "لسا مفيش",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),
                  ),
                )
              ]);
            }

            return ListView.builder(
              itemBuilder: (context, i) {
                BaseMarksFormModel form = churches.elementAt(i);
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
                                form.churchName!,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                form.levelInArabic,
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
                            builder: (context) => FormScreen(
                              form: form,
                              user: widget.user,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
              itemCount: churches.length,
            );
          },
        ),
      ),
    );
  }
}
