import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/core/services/storage_service/storage_service.dart';
import 'package:t7kem_al7an/features/user/images/view/screens/forms_images_screen.dart';
import 'package:t7kem_al7an/features/user/marks_forms/base_marks_form.dart';
import 'package:t7kem_al7an/features/user/marks_forms/form_screen.dart';

import '../../../../../core/di/service_locator.dart';
import '../../../../authentication/view/screens/auth_screen.dart';
import '../../../../authentication/model/user_model.dart';
import '../../../repository/i_user_repository.dart';
import '../../viewmodel/churches_cubit.dart';

class ChurchesScreen extends StatelessWidget {
  const ChurchesScreen({super.key, required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChurchesCubit(sl<IUserRepository>())..start(user),
      child: _ChurchesBody(user: user),
    );
  }
}

class _ChurchesBody extends StatefulWidget {
  const _ChurchesBody({required this.user});
  final UserModel user;

  @override
  State<_ChurchesBody> createState() => _ChurchesBodyState();
}

class _ChurchesBodyState extends State<_ChurchesBody> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الكنائس',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormsImagesScreen()),
              );
            },
            icon: const Icon(Icons.image),
          ),
          IconButton(
            onPressed: () {
              StorageService.instance.deleteUser();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade700, Colors.green.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<ChurchesCubit, ChurchesState>(
            builder: (context, state) {
              if (state is ChurchesInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (state is ChurchesError) {
                return const Center(
                  child: Text(
                    'حصلت مشكلة جرب تاني',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              }

              final churches = (state as ChurchesSuccess).churches;
              if (churches.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.church,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "لسا مفيش",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 26,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: churches.length,
                itemBuilder: (context, i) {
                  BaseMarksFormModel form = churches.elementAt(i);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormScreen(form: form, user: widget.user),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.green.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Icon(
                                        Icons.church,
                                        color: Colors.green.shade700,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            form.churchName!,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade700,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            form.levelInArabic,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}