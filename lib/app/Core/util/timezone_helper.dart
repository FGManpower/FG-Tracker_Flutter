import 'package:flutter_timezone/flutter_timezone.dart';

class TimeZoneHelper {
  static Future<String?> getTimeZone() async {
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      return timezone.identifier;
    } catch (e) {
      return null;
    }
  }
}