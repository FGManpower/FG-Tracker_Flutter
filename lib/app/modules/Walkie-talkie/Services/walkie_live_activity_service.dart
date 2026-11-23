import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fgtracker/app/Core/util/app_log.dart';

class WalkieLiveActivityService {
  WalkieLiveActivityService._();
  static final WalkieLiveActivityService instance =
      WalkieLiveActivityService._();

  static const MethodChannel _channel =
      MethodChannel('com.fg.walkie/live_activity');

  bool _isInitialized = false;

  void init() async {
    if (!Platform.isIOS || _isInitialized) return;
    _isInitialized = true;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onActivityPushToken') {
        final args = Map<String, dynamic>.from(call.arguments ?? {});
        AppLog.d("🔔 [WalkieLiveActivity] push token received: $args");
      }
    });

    try {
      final enabled = await isSupported();
      AppLog.d("🔔 [WalkieLiveActivity] areActivitiesEnabled: $enabled");
    } catch (_) {}
  }

  Future<bool> isSupported() async {
    if (!Platform.isIOS) return false;
    try {
      final res = await _channel.invokeMethod<bool>('isSupported');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<String?> start({
    required String groupId,
    required String groupName,
    required String speakerName,
    String? speakerImage,
    int? joinedCount,
  }) async {
    if (!Platform.isIOS) return null;
    try {
      final res = await _channel.invokeMethod<String>('startLiveActivity', {
        'groupId': groupId,
        'groupName': groupName,
        'speakerName': speakerName,
        'speakerImage': speakerImage ?? '',
        'joinedCount': joinedCount ?? 0,
      });
      AppLog.d("✅ [WalkieLiveActivity] Started Live Activity: $res");
      return res;
    } catch (e) {
      AppLog.d("❌ [WalkieLiveActivity] start error: $e");
      return null;
    }
  }

  Future<void> update({
    required String groupId,
    required String speakerName,
    String? speakerImage,
    int? joinedCount,
    bool isSpeaking = true,
  }) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('updateLiveActivity', {
        'groupId': groupId,
        'speakerName': speakerName,
        'speakerImage': speakerImage ?? '',
        'joinedCount': joinedCount ?? 0,
        'isSpeaking': isSpeaking,
      });
    } catch (e) {
      AppLog.d("❌ [WalkieLiveActivity] update error: $e");
    }
  }

  Future<void> stop(String groupId) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('stopLiveActivity', {'groupId': groupId});
      AppLog.d("🛑 [WalkieLiveActivity] Stopped Live Activity for group: $groupId");
    } catch (e) {
      AppLog.d("❌ [WalkieLiveActivity] stop error: $e");
    }
  }

  Future<void> stopAll() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('stopAllLiveActivities');
    } catch (_) {}
  }
}

