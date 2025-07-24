import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:t7kem_al7an/widgets/custom_form_field.dart';
import 'add_church_screen.dart';
import 'add_judge_screen.dart';
import 'check_status_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

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
                      icon: Icons.person_add,
                      title: 'أضف المحكمين',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddJudgeScreen(),
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
                      icon: Icons.notification_add,
                      title: "ابعت رسالة",
                      onTap: () async {
                        final titleController = TextEditingController();
                        final bodyController = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            backgroundColor: Colors.lightBlue.shade900,
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomTextFormField(
                                  textColor: Colors.amber.shade700,
                                  text:"العنوان",
                                  controller: titleController,
                                  floatingLabel: true,
                                ),
                                const SizedBox(height: 10),
                                CustomTextFormField(
                                  textColor: Colors.amber.shade700,
                                  text: "الرسالة",
                                  controller: bodyController,
                                  floatingLabel: true,
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.amber.shade700)),
                                  onPressed: () async {
                                    sendFcmMessage(
                                       titleController.text,
                                      bodyController.text,
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: const Text("ابعت"),
                                ),
                              ],
                            ),
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
                color: Colors.black.withOpacity(0.1),
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
Future<void> sendFcmMessage(String title,String body) async {
  // 1. Load service account credentials from assets
  final jsonStr = await rootBundle.loadString('assets/t7kem-al7an-firebase-adminsdk-fbsvc-d28c9e62f0.json');
  final credentials = ServiceAccountCredentials.fromJson(json.decode(jsonStr));

  // 2. Define scopes for FCM
  const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // 3. Get authenticated client
  final client = await clientViaServiceAccount(credentials, scopes);

  // 4. Construct the message
  final message = {
    "message": {
      "topic": "all",
      "notification": {
        "title": title,
        "body": body
      },
      "android": {
        "priority": "high"
      }
    }
  };

  const String projectId = "t7kem-al7an";
  final url = Uri.parse("https://fcm.googleapis.com/v1/projects/$projectId/messages:send");

  // 5. Send the message
  final response = await client.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(message),
  );

  print('FCM response: ${response.statusCode} => ${response.body}');
}
