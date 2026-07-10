import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/features/admin/judges/view/screens/add_judge_screen.dart';
import 'package:t7kem_al7an/features/admin/repository/i_admin_repository.dart';
import 'package:t7kem_al7an/features/user/churches/view/screens/churchs_screen.dart';
import '../../../../../core/di/service_locator.dart';
import '../../view_model/delete_judge/delete_judge_cubit.dart';
import '../../view_model/get_judges/get_judges_cubit.dart';

class JudgesScreen extends StatelessWidget {
  const JudgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => GetJudgesCubit(sl<IAdminRepository>())..start()),
        BlocProvider(create: (_) => DeleteJudgeCubit(sl<IAdminRepository>())),
      ],
      child: const _JudgesBody(),
    );
  }
}

class _JudgesBody extends StatefulWidget {
  const _JudgesBody();

  @override
  State<_JudgesBody> createState() => _JudgesBodyState();
}

class _JudgesBodyState extends State<_JudgesBody> {
  Future<void> _confirmAndDelete(String docId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد حذف هذا المحكم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('نعم'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;
    if (!mounted) return;

    context.read<DeleteJudgeCubit>().deleteJudge(docId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteJudgeCubit, DeleteJudgeState>(
      listener: (context, state) {
        if (state is DeleteJudgeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        // JudgesCubit's stream will emit a new JudgesLoaded automatically
        // once Firestore reflects the delete — no manual refresh needed.
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'المحكمين',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue.shade700,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddJudgeScreen()),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
        body: Container(
          height: MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade700, Colors.blue.shade50],
            ),
          ),
          child: BlocBuilder<GetJudgesCubit, GetJudgesState>(
            builder: (context, state) {
              if (state is GetJudgesLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GetJudgesError) {
                return const Center(child: Text('حصلت مشكلة جرب تاني'));
              }

              final judges = (state as GetJudgesLoaded).judges;
              if (judges.isEmpty) {
                return const Center(child: Text('لا يوجد محكمين'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: judges.length,
                itemBuilder: (context, index) {
                  final user = judges[index];

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChurchesScreen(user: user)),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child:
                              Icon(Icons.person, color: Colors.blue.shade700),
                        ),
                        title: Text(
                          user.name.toString(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddJudgeScreen(
                                    initialUser: user,
                                  ),
                                ),
                              );
                            }
                            if (value == 'delete') {
                              _confirmAndDelete(user.docId!);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('تعديل')),
                            PopupMenuItem(value: 'delete', child: Text('حذف')),
                          ],
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
