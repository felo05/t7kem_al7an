import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/features/admin/home/view/screens/home_screen.dart';
import 'package:t7kem_al7an/features/authentication/view_model/auth_cubit.dart';
import 'package:t7kem_al7an/features/user/churches/view/screens/churchs_screen.dart';

import '../../../../core/di/service_locator.dart';
import '../../repository/i_authentication_repository.dart';
import '/core/widgets/custom_form_field.dart';
import '/core/widgets/marks_form_fields.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _passController = TextEditingController();

  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _passController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onLogin(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    context.read<LoginCubit>().login(
          _nameController.text.trim(),
          _passController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(sl<IAuthenticationRepository>()),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    Image.asset(
                      "assets/images/logo.png",
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 50),
                    CustomTextFormField(
                      text: "الاسم",
                      controller: _nameController,
                      floatingLabel: true,
                      autofocus: true,
                      autofillHints: const [AutofillHints.username],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "من فضلك ادخل الاسم";
                        }
                        return null;
                      },
                      onSubmit: (_) {
                        FocusScope.of(context).requestFocus(_passwordFocus);
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      text: "الباسورد",
                      controller: _passController,
                      floatingLabel: true,
                      isPassword: true,
                      currentFocusNode: _passwordFocus,
                      autofillHints: const [AutofillHints.password],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "من فضلك ادخل الباسورد";
                        }
                        return null;
                      },
                      onSubmit: (_) => _onLogin(context),
                    ),
                    const SizedBox(height: 20),
                    BlocConsumer<LoginCubit, LoginState>(
                      listener: (context, state) {
                        if (state is LoginSuccessState) {
                          TextInput.finishAutofillContext();

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => state.user.isAdmin
                                  ? const HomeScreen()
                                  : ChurchesScreen(user: state.user),
                            ),
                          );
                        } else if (state is LoginErrorState) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                state.message ?? "جرب تاني",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is LoginLoadingState) {
                          return const CircularProgressIndicator(
                            color: Colors.indigo,
                          );
                        }

                        return MarksFormFields.submitButton(
                          onPressed: () => _onLogin(context),
                          text: "دخول",
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
