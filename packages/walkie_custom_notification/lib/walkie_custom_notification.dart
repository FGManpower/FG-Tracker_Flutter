import 'package:flutter/services.dart';

class WalkieCustomNotification {
  static const MethodChannel _channel = MethodChannel('com.fg.walkie/notification');
  static void Function(Map<String, dynamic>)? _actionListener;

  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onWalkieAction') {
        final data = Map<String, dynamic>.from(call.arguments ?? {});
        _actionListener?.call(data);
      }
    });
  }

  static void setActionListener(void Function(Map<String, dynamic>) listener) {
    _actionListener = listener;
  }

  static Future<bool> show({
    required String speakerName,
    required String groupName,
    required String groupId,
    String? speakerImage,
    int? joinedCount,
  }) async {
    try {
      final res = await _channel.invokeMethod<bool>('showNotification', {
        'speakerName': speakerName,
        'groupName': groupName,
        'groupId': groupId,
        'speakerImage': speakerImage ?? '',
        'joinedCount': joinedCount,
      });
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> cancel() async {
    try {
      await _channel.invokeMethod('cancelNotification');
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> getInitialAction() async {
    try {
      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>('getInitialAction');
      if (res != null) {
        return Map<String, dynamic>.from(res);
      }
    } catch (_) {}
    return null;
  }
}
