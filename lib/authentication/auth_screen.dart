import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:t7kem_al7an/authentication/cubit/auth_cubit.dart';
import 'package:t7kem_al7an/churches/churchs_screen.dart';

import '../screens/admin_screen.dart';
import '../widgets/custom_form_field.dart';
import '../widgets/marks_form_fields.dart';

class AuthScreen extends StatelessWidget {
  Future<bool> checkAndRequestPermissions({required bool skipIfExists}) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return false; // Only Android and iOS platforms are supported
    }

    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;

      if (skipIfExists) {
        // Read permission is required to check if the file already exists
        return sdkInt >= 33
            ? await Permission.photos.request().isGranted
            : await Permission.storage.request().isGranted;
      } else {
        // No read permission required for Android SDK 29 and above
        return sdkInt >= 29 ? true : await Permission.storage.request().isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS permission for saving images to the gallery
      return skipIfExists
          ? await Permission.photos.request().isGranted
          : await Permission.photosAddOnly.request().isGranted;
    }

    return false; // Unsupported platforms
  }

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    checkAndRequestPermissions(skipIfExists: true);
    TextEditingController nameController = TextEditingController();
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 100),
                  Image.asset(
                    "assets/images/logo.png",
                    width: 250,
                    height: 250,
                  ),
                  const SizedBox(height: 100),
                  CustomTextFormField(
                    text: 'الاسم',
                    controller: nameController,
                    floatingLabel: true,
                  ),
                  const SizedBox(height: 20),
                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthSuccess) {
                        Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) =>  state.isAadmin?const AdminScreen():ChurchesScreen(data: state.data!,)),
                        (route) => false);
                      }
                      else if (state is AuthError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message??"جرب تاني",style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 20),),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.indigo,),
                        );
                      }
                      return MarksFormFields.submitButton(onPressed: (){
                        context.read<AuthCubit>().login(nameController.text);
                      },text: "دخول");
                    },
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
