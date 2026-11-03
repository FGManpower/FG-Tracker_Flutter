import 'package:flutter/widgets.dart';

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
  static void openGroup(int groupId) => _groupId = groupId;

  static void closeGroup(int groupId) {
    if (_groupId == groupId) _groupId = null;
  }

  // ---- Private chat ----
  static void openPrivate({required String peerUserId, String? chatId}) {
    _privatePeerId = peerUserId;
    if (chatId != null && chatId.isNotEmpty && chatId != 'null') {
      _privateChatId = chatId;
    }
  }

  static void setPrivateChatId(String peerUserId, String chatId) {
    if (_privatePeerId == peerUserId && chatId.isNotEmpty) {
      _privateChatId = chatId;
    }
  }

  static void closePrivate(String peerUserId) {
    if (_privatePeerId != peerUserId) return;
    _privatePeerId = null;
    _privateChatId = null;
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
