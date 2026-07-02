import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:t7kem_al7an/core/widgets/custom_form_field.dart';

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
  bool _isLoading = false;
  String _selectedTarget = 'all';

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
                    onChanged: (value) {
                      setState(() {});
                    },
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
                  const SizedBox(height: 20),
                  // Character Count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'العنوان: ${_titleController.text.length}/65',
                          style: TextStyle(
                            color: _titleController.text.length > 65
                                ? Colors.red
                                : Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'المحتوى: ${_bodyController.text.length}/240',
                          style: TextStyle(
                            color: _bodyController.text.length > 240
                                ? Colors.red
                                : Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Send Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendNotification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'إرسال الإشعار',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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

  Future<void> _sendNotification() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _sendFcmMessage(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          target: _selectedTarget,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال الإشعار بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          // Clear form
          _titleController.clear();
          _bodyController.clear();
          setState(() {
            _selectedTarget = 'all';
          });
        }
      } catch (e) {
        print('Error sending notification: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في إرسال الإشعار: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _sendFcmMessage({
    required String title,
    required String body,
    required String target,
  }) async {
    try {
      // 1. Load service account credentials from assets
      final jsonStr = await rootBundle.loadString(
          'assets/t7kem-al7an-c4a5f-5b9f2aaa218d.json');
      final credentials =
          ServiceAccountCredentials.fromJson(json.decode(jsonStr));

      // 2. Define scopes for FCM
      const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      // 3. Get authenticated client
      final client = await clientViaServiceAccount(credentials, scopes);

      // 4. Determine the target topic
      String targetTopic = 'all'; // default
      if (target == 'judges') {
        targetTopic = 'judges';
      } else if (target == 'coordinators') {
        targetTopic = 'coordinators';
      }

      // 5. Construct the message
      final message = {
        "message": {
          "topic": targetTopic,
          "notification": {
            "title": title,
            "body": body,
          },
          "android": {
            "priority": "high",
            "notification": {
              "sound": "default",
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
            }
          },
          "apns": {
            "payload": {
              "aps": {
                "alert": {
                  "title": title,
                  "body": body,
                },
                "sound": "default",
              }
            }
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "status": "done",
            "timestamp": DateTime.now().toIso8601String(),
          }
        }
      };

        const String projectId = "t7kem-al7an-c4a5f";
      final url = Uri.parse(
          "https://fcm.googleapis.com/v1/projects/$projectId/messages:send");

      // 6. Send the message
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(message),
      );

      print('FCM response: ${response.statusCode} => ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to send notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM message: $e');
      rethrow;
    }
  }
}



