import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/core/widgets/custom_form_field.dart';
import 'package:t7kem_al7an/features/admin/repository/i_admin_repository.dart';
import '../../../../../core/di/service_locator.dart';
import '../../view_model/push_notifications_cubit.dart';

class PushNotificationsScreen extends StatefulWidget {
  const PushNotificationsScreen({super.key});

  @override
  State<PushNotificationsScreen> createState() =>
      _PushNotificationsScreenState();
}

class _PushNotificationsScreenState extends State<PushNotificationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إرسال إشعارات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade700,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 20.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          size: 64,
                          color: Colors.purple.shade700,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'إرسال إشعار جماعي',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Title Input
                  CustomTextFormField(
                    text: 'عنوان الإشعار',
                    controller: _titleController,
                    prefixIcon: Icons.title,
                    onChanged: (value) {
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'برجاء إدخال عنوان الإشعار';
                      }
                      if (value.length > 65) {
                        return 'العنوان يجب أن لا يتجاوز 65 حرف';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Body Input
                  CustomTextFormField(
                    text: 'محتوى الإشعار',
                    controller: _bodyController,
                    prefixIcon: Icons.message,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'برجاء إدخال محتوى الإشعار';
                      }
                      if (value.length > 240) {
                        return 'المحتوى يجب أن لا يتجاوز 240 حرف';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  // Send Button
                  BlocProvider(
                    create: (context) =>
                        PushNotificationsCubit(sl<IAdminRepository>()),
                    child: BlocConsumer<PushNotificationsCubit,
                        PushNotificationsState>(
                      listener: (context, state) {
                        if(state is PushNotificationsError){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('حدث خطأ ما'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                        else if (state is PushNotificationsSuccess){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إرسال الإشعار بنجاح'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is PushNotificationsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final title = _titleController.text.trim();
                              final body = _bodyController.text.trim();
                              context
                                  .read<PushNotificationsCubit>()
                                  .sendPushNotification(
                                    title: title,
                                    body: body,
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'إرسال الإشعار',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
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
