import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/core/services/storage_service/storage_service.dart';
import 'package:t7kem_al7an/features/user/churches/cubit/churches_cubit.dart';
import 'package:t7kem_al7an/features/user/images/forms_images_screen.dart';
import 'package:t7kem_al7an/features/user/marks_forms/base_marks_form.dart';
import 'package:t7kem_al7an/features/user/marks_forms/form_screen.dart';

import '../../authentication/view/screens/auth_screen.dart';
import '../../authentication/model/user_model.dart';

class ChurchesScreen extends StatelessWidget {
  const ChurchesScreen({super.key, required this.user});
  final UserModel user;

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
  final UserModel user;

  @override
  State<_ChurchesBody> createState() => _ChurchesBodyState();
}

class _ChurchesBodyState extends State<_ChurchesBody> {
  late final Stream<List<BaseMarksFormModel>> _churchesStream;
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _churchesStream = context.read<ChurchesCubit>().watchChurches(widget.user);
    _loadImagePaths();
  }

  Future<void> _loadImagePaths() async {
    final paths = await StorageService.instance.getFormImagePaths();
    setState(() {
      _imagePaths = paths;
    });
  }

  bool _hasImageForChurch(String churchName) {
    final searchPattern = '${churchName}_${widget.user.name}';
    return _imagePaths.any((path) => path.contains(searchPattern));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الكنائس',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
                MaterialPageRoute(
                  builder: (context) => const FormsImagesScreen(),
                ),
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
            colors: [
              Colors.green.shade700,
              Colors.green.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<List<BaseMarksFormModel>>(
            stream: _churchesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'حصلت مشكلة جرب تاني',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              }

              final churches = snapshot.data ?? [];
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
                itemBuilder: (context, i) {
                  BaseMarksFormModel form = churches.elementAt(i);
                  bool hasImage = _hasImageForChurch(form.churchName ?? '');

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: InkWell(
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
                      borderRadius: BorderRadius.circular(16),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.green.shade50,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Padding(
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
                                            borderRadius:
                                                BorderRadius.circular(25),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                form.churchName!,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade700,
                                                ),
                                                overflow:
                                                    TextOverflow.ellipsis,
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
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Image icon in top-right corner
                              if (hasImage)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FormsImagesScreen(
                                            churchName:
                                                form.churchName ?? '',
                                            userName: widget.user.name,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade700,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: churches.length,
              );
            },
          ),
        ),
      ),
    );
  }
}
