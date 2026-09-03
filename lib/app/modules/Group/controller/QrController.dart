import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';

import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class QrController extends GetxController {
  var groupCode = "".obs;


  final ScreenshotController screenshotController = ScreenshotController();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> shareQrCode(
    BuildContext context,
    String groupCode,
  ) async {
    try {
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      final image = await screenshotController.capture();

      if (image == null) {
        log("Screenshot failed");
        return;
      }

      final tempDir = await getTemporaryDirectory();

      final file = await File(
        '${tempDir.path}/qr_code.png',
      ).create();

      await file.writeAsBytes(image);

      const String appLink =
          'https://play.google.com/store/apps/details?id=com.fg.fgtracker';

      final String message = '''
📌 Group Code: $groupCode

Join my group instantly using the QR code or the code above.

📲 Download the app to stay connected:
$appLink
''';

      final RenderBox box = context.findRenderObject() as RenderBox;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: message,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      log("Error sharing QR code: $e");
    }
  }

  Future<void> downloadQrCode(BuildContext context) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final image = await screenshotController.capture();

      if (image == null) {
        log("Screenshot capture failed");
        return;
      }

      final directory = await getTemporaryDirectory();

      final filePath =
          '${directory.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';

      final file = File(filePath);

      await file.writeAsBytes(image);

      await Gal.putImage(file.path);

      _showDownloadNotification(filePath);

      log("QR saved successfully");
    } catch (e) {
      log("Download Error: $e");
    }
  }

  void _showDownloadNotification(String filePath) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'download_channel',
      'Download Notifications',
      channelDescription: 'Notifies when QR code is downloaded',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'QR Code Saved',
      'Tap to open your QR code',
      notificationDetails,
      payload: filePath,
    );
  }

  Future<void> initializeNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        onNotificationClick(payload.payload);
      },
    );
  }

  Future<void> onNotificationClick(String? payload) async {
    if (payload != null) {
      await OpenFile.open(payload);
    }
  }
}
