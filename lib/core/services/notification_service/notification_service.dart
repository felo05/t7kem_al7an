import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification({
    required String? title,
    required String? body,
    String? imageUrl,
  }) async {
    BigPictureStyleInformation? bigPictureStyleInformation;

    if (imageUrl != null) {
      final ByteArrayAndroidBitmap largeIcon = await _downloadAndSaveImage(imageUrl, 'largeIcon');
      final ByteArrayAndroidBitmap bigPicture = await _downloadAndSaveImage(imageUrl, 'bigPicture');

      bigPictureStyleInformation = BigPictureStyleInformation(
        bigPicture,
        largeIcon: largeIcon,
        contentTitle: title,
        summaryText: body,
      );
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<ByteArrayAndroidBitmap> _downloadAndSaveImage(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';

    final http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      await File(filePath).writeAsBytes(response.bodyBytes);
      final Uint8List imageBytes = await File(filePath).readAsBytes();
      return ByteArrayAndroidBitmap(imageBytes);
    } else {
      throw Exception('Error downloading image: ${response.statusCode}');
    }
  }

}
