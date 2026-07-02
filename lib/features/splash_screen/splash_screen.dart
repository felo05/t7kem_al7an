import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t7kem_al7an/features/admin/screens/admin_screen.dart';
import 'package:t7kem_al7an/features/authentication/auth_screen.dart';
import 'package:t7kem_al7an/features/splash_screen/cubit/splash_cubit.dart';
import 'package:t7kem_al7an/features/user/churches/churchs_screen.dart';

import '../../core/services/shorebird_service/shorebird_service.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ShorebirdUpdateService.instance.checkAndForceRestart(context);
    return BlocProvider(
      create: (context) => SplashCubit()..checkAuth(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is NotLoggedIn) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AuthScreen()),
            );
          }

          if (state is LoggedIn) {
            if (state.user.isAdmin) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AdminScreen()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ChurchesScreen(user: state.user),
                ),
              );
            }
          }
        },
        child: const Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 75),
                Center(
                  child: Image(
                    image: AssetImage('assets/images/logo.png'),
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 200),
                Center(
                  child: CircularProgressIndicator(
                    constraints: BoxConstraints(
                      minWidth: 50,
                      minHeight: 50,
                      maxWidth: 50,
                      maxHeight: 50,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}