import 'package:flutter/services.dart';

const platform = MethodChannel("app.restart.channel");

class RestartHelper{
  Future<void> restartApplication() async {
    try {
      await platform.invokeMethod("restartApp");
    } catch (e) {
      print("Failed to restart app: $e");
    }
  }
}