

import 'package:http/http.dart' as http;

class RemoteLoggerTest {
  static const String _webhookUrl = "https://webhook.site/9246f70a-7e8d-4ab4-8f8f-01846e2c3464";

  static Future<void> log(String tag, String message) async {
    try {
      print("[$tag] $message");
      await http.post(
        Uri.parse(_webhookUrl),
        body: {
          "tag": tag,
          "time": DateTime.now().toIso8601String(),
          "log": message,
        },
      ).timeout(const Duration(seconds: 4));
    } catch (_) {}
  }
}