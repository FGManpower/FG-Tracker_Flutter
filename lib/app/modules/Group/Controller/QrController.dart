import 'dart:developer';
import 'dart:io';

import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class QrController extends GetxController{
  final ScreenshotController screenshotController = ScreenshotController();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> shareQrCode(String groupCode) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final image = await screenshotController.capture();
      if (image == null) {
        log("Screenshot failed");
        return;
      }


      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_code.png').create();
      await file.writeAsBytes(image);

      const String appLink = 'https://play.google.com/store/apps/details?id=com.fg.fgtracker';
      final String message = '''
📌 *Group Code*: $groupCode

Join my group instantly using the QR code or the code above.
📲 Download the app to stay connected: $appLink
''';

      // Share image and message
      await Share.shareXFiles(
        [XFile(file.path)],
        text: message,
      );
    } catch (e) {
      log("Error sharing QR code: $e");
    }
  }



  Future<void> downloadQrCode(BuildContext context) async {
    PermissionStatus imagePermission = await Permission.photos.request();
    PermissionStatus videoPermission = await Permission.videos.request();

    bool isGranted = imagePermission.isGranted || videoPermission.isGranted;

    if (!isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Text("Image/Storage permission denied. Please allow it to continue.",style: TextStyle(
              color: Colors.white,fontSize: 13.sp,),),
          action: SnackBarAction(textColor: Colors.white,
            label: "Open Settings",backgroundColor: AppColors.darkBlue,
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
      return;
    }

    final image = await screenshotController.capture();
    if (image != null) {
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(image);

      _showDownloadNotification(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("QR Code downloaded successfully")),
      );
    }
  }



  void _showDownloadNotification(String filePath) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
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