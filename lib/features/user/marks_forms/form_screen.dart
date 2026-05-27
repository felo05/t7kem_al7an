import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/core/widgets/marks_form_fields.dart';
import '../../authentication/user.dart';
import 'base_marks_form.dart';
import 'cubit/submit_cubit.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.form, required this.user});

  final BaseMarksFormModel form;
  final User user;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  @override
  void dispose() {
    widget.form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.form.levelInArabic,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
      ),
      body: Center(
        child: Column(
          children: [
            widget.form.view(),
            const SizedBox(height: 20),
            BlocProvider(
              create: (context) => SubmitCubit(),
              child: BlocConsumer<SubmitCubit, SubmitState>(
                listener: (context, state) {
                  if (state is SubmitSuccess) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("تم تسليم الاستمارة بنجاح!"),
                      backgroundColor: Colors.green,
                    ));
                  } else if (state is SubmitFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
                builder: (context, state) {
                  if (state is SubmitLoading) {
                    return const CircularProgressIndicator();
                  }
                  return MarksFormFields.submitButton(
                    onPressed: () async {
                      if (widget.form.validate()) {
                        context.read<SubmitCubit>().submitForm(
                            () => widget.form.submit(widget.user.name));
                      }
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
