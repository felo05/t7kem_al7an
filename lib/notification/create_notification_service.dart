import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CreateNotificationService {
  static final CreateNotificationService _notificationService =
  CreateNotificationService._internal();

  factory CreateNotificationService() {
    return _notificationService;
  }

  CreateNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
    DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification,
    );
  }

  Future<void> showNotificationWithImage(
      int id, String title, String body, String payload, String? imageUrl) async {

    AndroidNotificationDetails androidNotificationDetails;
    DarwinNotificationDetails iosNotificationDetails;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Download and save image for Android and iOS
      final String largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');
      final String imagePath = await _downloadAndSaveFile(imageUrl, 'image');

      // Create BigPictureStyleInformation for Android
      final BigPictureStyleInformation bigPictureStyleInformation =
      BigPictureStyleInformation(
        FilePathAndroidBitmap(largeIconPath),
        largeIcon: FilePathAndroidBitmap(largeIconPath),
        contentTitle: title,
        summaryText: body,
      );

      // Create AndroidNotificationDetails with image
      androidNotificationDetails = AndroidNotificationDetails(
        'channelId',
        'channelName',
        styleInformation: bigPictureStyleInformation,
        importance: Importance.max,
        priority: Priority.high,
      );

      // Create iOSNotificationDetails with image
      iosNotificationDetails = DarwinNotificationDetails(
        attachments: [
          DarwinNotificationAttachment(imagePath),
        ],
      );
    } else {
      // Create basic AndroidNotificationDetails without image
      androidNotificationDetails = const AndroidNotificationDetails(
        'channelId',
        'channelName',
        importance: Importance.max,
        priority: Priority.high,
      );

      // Create basic iOSNotificationDetails without image
      iosNotificationDetails = const DarwinNotificationDetails();
    }

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }


  Future<void> onSelectNotification(NotificationResponse notificationResponse) async {
    String? payload = notificationResponse.payload;
    if (payload != null) {
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final File file = File(filePath);

    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download image');
    }

    return filePath;
  }
}
