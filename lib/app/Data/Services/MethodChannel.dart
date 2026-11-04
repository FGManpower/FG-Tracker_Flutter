import 'package:flutter/services.dart';
import '../../Core/util/app_log.dart';

const platform = MethodChannel("app.restart.channel");

class RestartHelper {
  Future<void> restartApplication() async {
    try {
      await platform.invokeMethod("restartApp");
    } catch (e) {
      AppLog.e("Failed to restart app: $e");
    }
  }
}