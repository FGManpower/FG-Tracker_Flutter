import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHolder {
  static NotificationResponse? pendingResponse;

  static void clear() {
    pendingResponse = null;
  }
}

class AppLaunchTracker {
  static bool fromTerminatedCall = false;
}
