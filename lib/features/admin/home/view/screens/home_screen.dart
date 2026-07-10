import 'package:flutter/material.dart';
import 'package:t7kem_al7an/features/admin/judges/view/screens/judges_screen.dart';
import 'package:t7kem_al7an/features/authentication/view/screens/auth_screen.dart';
import '../../../../../core/services/storage_service/storage_service.dart';
import '../../../churches_adding/view/screens/add_church_screen.dart';
import '../../../judges_assigning/view/screens/assign_judge_screen.dart';
import '../../../results/view/screens/check_status_screen.dart';
import '../../../push_notifications/view/screens/push_notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'صفحة المنسق',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              StorageService.instance.deleteUser();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.white, size: 24),
          )
        ],
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  _buildAdminButton(
                    context,
                    icon: Icons.church,
                    title: 'أضف اللجان',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddChurchScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildAdminButton(
                    context,
                    icon: Icons.people,
                    title: 'المحكمين',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JudgesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildAdminButton(
                    context,
                    icon: Icons.person_add,
                    title: 'تسكين المحكمين',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AssignJudgeScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildAdminButton(
                    context,
                    icon: Icons.analytics,
                    title: 'النتائج',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckStatusScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildAdminButton(
                    context,
                    icon: Icons.notifications_active,
                    title: 'إرسال إشعارات',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PushNotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue.shade700,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
