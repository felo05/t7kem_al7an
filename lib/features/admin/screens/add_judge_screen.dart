import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:t7kem_al7an/core/constants/firebase_constants.dart';
import 'package:t7kem_al7an/core/widgets/custom_form_field.dart';
import 'package:t7kem_al7an/core/widgets/marks_form_fields.dart';
import 'package:t7kem_al7an/features/authentication/model/user_model.dart';

class AddJudgeScreen extends StatefulWidget {
  const AddJudgeScreen({super.key, this.userId, this.initialUser,});

  final String? userId;
  final UserModel? initialUser;

  @override
  State<AddJudgeScreen> createState() => _AddJudgeScreenState();
}

class _AddJudgeScreenState extends State<AddJudgeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  late UserModel _user;
  bool _isSubmitting = false;

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

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final pass = _passController.text.trim();

    if (name.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ادخل الاسم والباسورد')),
      );
      return;
    }

    final userToSave = UserModel(name: name, isAdmin: _user.isAdmin);

    setState(() {
      _isSubmitting = true;
    });

    try {
      final usersRef = FirebaseFirestore.instance.collection(FirebaseConstants.users);
      if (widget.userId == null) {
        await usersRef.add({
          FirebaseConstants.name: userToSave.name,
          'pass': pass,
          'isAdmin': userToSave.isAdmin,
        });
      } else {
        await usersRef.doc(widget.userId).update({
          FirebaseConstants.name: userToSave.name,
          'pass': pass,
          'isAdmin': userToSave.isAdmin,
        });
      }

      if (!mounted) {
        return;
      }

      if (widget.userId == null) {
        _nameController.clear();
        _passController.clear();
        setState(() {
          _user = UserModel(name: '', isAdmin: false);
        });
      } else {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.userId == null ? 'تم اضافه المستخدم' : 'تم تعديل المستخدم')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حصلت مشكلة جرب تاني')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.userId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'تعديل محكم' : 'اضافة محكم',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade50,
            ],
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
                  _isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : MarksFormFields.submitButton(
                          onPressed: _submit,
                          text: isEditing ? 'تعديل' : 'اضافة',
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}