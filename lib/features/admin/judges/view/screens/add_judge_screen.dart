import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/core/widgets/custom_form_field.dart';
import 'package:t7kem_al7an/core/widgets/marks_form_fields.dart';
import 'package:t7kem_al7an/features/admin/repository/i_admin_repository.dart';
import 'package:t7kem_al7an/features/authentication/model/user_model.dart';

import '../../../../../core/di/service_locator.dart';
import '../../view_model/add_judge/add_judge_cubit.dart';

class AddJudgeScreen extends StatelessWidget {
  const AddJudgeScreen({super.key, this.initialUser});

  final UserModel? initialUser;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddJudgeCubit(sl<IAdminRepository>()),
      child: _AddJudgeBody(initialUser: initialUser),
    );
  }
}

class _AddJudgeBody extends StatefulWidget {
  const _AddJudgeBody({this.initialUser});

  final UserModel? initialUser;

  @override
  State<_AddJudgeBody> createState() => _AddJudgeBodyState();
}

class _AddJudgeBodyState extends State<_AddJudgeBody> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    if (widget.initialUser?.name != null) {
      _nameController.text = widget.initialUser!.name;
    }
    _user = widget.initialUser ?? UserModel(name: '', isAdmin: false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final pass = _passController.text.trim();

    if (name.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ادخل الاسم والباسورد')),
      );
      return;
    }

    context.read<AddJudgeCubit>().submit(UserModel(
        name: name,
        isAdmin: _user.isAdmin,
        password: pass,
        docId: widget.initialUser?.docId));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialUser?.docId != null;

    return BlocListener<AddJudgeCubit, AddJudgeState>(
      listener: (context, state) {
        if (state is AddJudgeSuccess) {
          if (state.isEditing) {
            Navigator.of(context).pop();
          } else {
            _nameController.clear();
            _passController.clear();
            setState(() {
              _user = UserModel(name: '', isAdmin: false);
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.isEditing
                    ? 'تم تعديل المستخدم'
                    : 'تم اضافه المستخدم')),
          );
        } else if (state is AddJudgeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditing ? 'تعديل محكم' : 'اضافة محكم',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue.shade700,
          elevation: 0,
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
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      text: 'الاسم',
                      controller: _nameController,
                      floatingLabel: true,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      text: 'الباسورد',
                      controller: _passController,
                      floatingLabel: true,
                      isPassword: true,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: _user.isAdmin,
                          activeThumbColor: Colors.amberAccent,
                          onChanged: (value) {
                            setState(() {
                              _user = UserModel(
                                name: _nameController.text.trim(),
                                isAdmin: value,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<AddJudgeCubit, AddJudgeState>(
                      builder: (context, state) {
                        if (state is AddJudgeLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return MarksFormFields.submitButton(
                          onPressed: _submit,
                          text: isEditing ? 'تعديل' : 'اضافة',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
