import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';

/// Which chat screen is open right now. Used so messages arriving in the open
/// chat are marked read immediately, and so the chat list doesn't show an
/// unread badge for the chat the user is looking at.
class ActiveChatTracker {
  ActiveChatTracker._();

  static int? _groupId;
  static String? _privateChatId;
  static String? _privatePeerId;

  static bool get isAppInForeground {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  }

  // ---- Group chat ----
  static void openGroup(int groupId) {
    _groupId = groupId;
    _syncNative();
  }

  static void closeGroup(int groupId) {
    if (_groupId == groupId) _groupId = null;
    _syncNative();
  }

  // ---- Private chat ----
  static void openPrivate({required String peerUserId, String? chatId}) {
    _privatePeerId = peerUserId;
    if (chatId != null && chatId.isNotEmpty && chatId != 'null') {
      _privateChatId = chatId;
    }
    _syncNative();
  }

  static void setPrivateChatId(String peerUserId, String chatId) {
    if (_privatePeerId == peerUserId && chatId.isNotEmpty) {
      _privateChatId = chatId;
    }
    _syncNative();
  }

  static void closePrivate(String peerUserId) {
    if (_privatePeerId != peerUserId) return;
    _privatePeerId = null;
    _privateChatId = null;
    _syncNative();
  }

  // ---- iOS foreground banner suppression ----
  /// iOS only: tells AppDelegate which chat is open so it can skip the
  /// foreground banner for it (backend v2.8.0 §14.2). Android filters in Dart
  /// (NotificationServices._isChatNotificationForOpenChatOrSelf).
  static const MethodChannel _channel = MethodChannel('fgtracker/active_chat');

  static void _syncNative() {
    try {
      if (!Platform.isIOS) return;
      String? myUserId;
      try {
        myUserId = Global.storageServices.get(PrefConst.userId)?.toString();
      } catch (_) {}
      _channel.invokeMethod('set', <String, String?>{
        'groupId': _groupId?.toString(),
        'chatId': _privateChatId,
        'peerId': _privatePeerId,
        'myUserId': myUserId,
      }).catchError((_) => null);
    } catch (_) {}
  }

  /// True when the user is looking at this chat (open and app in foreground).
  static bool isViewing({
    bool isGroup = false,
    dynamic groupId,
    dynamic chatId,
    dynamic peerUserId,
  }) {
    if (!isAppInForeground) return false;
    String? s(dynamic v) {
      final str = v?.toString().trim();
      return (str == null || str.isEmpty || str == 'null') ? null : str;
    }

    if (isGroup) {
      final g = s(groupId);
      return g != null && _groupId != null && g == _groupId.toString();
    }
    final c = s(chatId);
    final p = s(peerUserId);
    return (c != null && c == _privateChatId) ||
        (p != null && p == _privatePeerId);
  }
}
