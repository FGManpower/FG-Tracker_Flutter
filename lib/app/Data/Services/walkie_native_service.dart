import 'package:flutter/services.dart';

class WalkieNativeService {
  static const _ch = MethodChannel("walkie_native");

  static Future<void> start({
    required String myUserId,
    required String remoteUserId,
  }) =>
      _ch.invokeMethod("startService", {
        "myUserId": myUserId,
        "remoteUserId": remoteUserId,
      });

  static Future<void> talk() =>
      _ch.invokeMethod("startTalking");

  static Future<void> stop() =>
      _ch.invokeMethod("stopTalking");

  static Future<void> saveUserId(String userId) async {
    await _ch.invokeMethod("saveUserId", {
      "userId": userId,
    });
    print("============Native in Saved Successfully======");
  }
}
