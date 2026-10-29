import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../Model/initialize_model.dart';

class NotificationMarkerService extends GetxService {
  static NotificationMarkerService get instance {
    if (!Get.isRegistered<NotificationMarkerService>()) {
      return Get.put(NotificationMarkerService(), permanent: true);
    }
    return Get.find<NotificationMarkerService>();
  }

  /// Marker for missed incoming calls (Private or Group calls).
  final RxBool hasCallingMarker = false.obs;

  /// Marker for unread messages in Private or Group chats.
  final RxBool hasChattingMarker = false.obs;

  /// Marker for active speaker on a Walkie-Talkie channel with notifications ON.
  final RxBool hasWalkieMarker = false.obs;

  /// Specific sub-markers to prevent one chat source from wiping the other
  final RxBool hasGroupChatUnread = false.obs;
  final RxBool hasPrivateChatUnread = false.obs;

  void _syncChattingMarker() {
    hasChattingMarker.value =
        hasGroupChatUnread.value || hasPrivateChatUnread.value;
  }

  void setPrivateChatUnread(bool hasUnread) {
    hasPrivateChatUnread.value = hasUnread;
    if (hasUnread) {
      hasChattingMarker.value = true;
    } else {
      _syncChattingMarker();
    }
  }

  void setGroupChatUnread(bool hasUnread) {
    hasGroupChatUnread.value = hasUnread;
    if (hasUnread) {
      hasChattingMarker.value = true;
    } else {
      _syncChattingMarker();
    }
  }

  /// Update marker states from a raw map (e.g. from /initialize API or Socket events)
  void updateFromMap(Map<dynamic, dynamic>? markers) {
    if (markers == null) return;

    // If whole data object is passed with notificationMarkers or notifications
    if (markers['notificationMarkers'] is Map) {
      updateFromMap(markers['notificationMarkers'] as Map);
      return;
    }
    if (markers['notifications'] is Map) {
      updateFromMap(markers['notifications'] as Map);
      return;
    }

    if (markers.containsKey('calling')) {
      hasCallingMarker.value = NotificationMarkers.parseMarkerBool(markers['calling']);
    }

    if (markers.containsKey('walkie')) {
      final val = markers['walkie'];
      if (val is Map) {
        hasWalkieMarker.value = val['hasNotification'] == true ||
            val['isChannelSpeaking'] == true ||
            val['hasActiveTalk'] == true;
      } else {
        hasWalkieMarker.value = NotificationMarkers.parseMarkerBool(val);
      }
    }

    // Parse specific sub-chat markers if provided
    final bool hasPrivateChatKey = markers.containsKey('privateChat') ||
        markers.containsKey('private_chat') ||
        markers.containsKey('private');
    if (hasPrivateChatKey) {
      final val = markers['privateChat'] ??
          markers['private_chat'] ??
          markers['private'];
      hasPrivateChatUnread.value = NotificationMarkers.parseMarkerBool(val);
    }

    final bool hasGroupChatKey = markers.containsKey('groupChat') ||
        markers.containsKey('group_chat') ||
        markers.containsKey('group');
    if (hasGroupChatKey) {
      final val = markers['groupChat'] ??
          markers['group_chat'] ??
          markers['group'];
      hasGroupChatUnread.value = NotificationMarkers.parseMarkerBool(val);
    }

    if (markers.containsKey('chatting') || markers.containsKey('chat')) {
      final val = markers['chatting'] ?? markers['chat'];
      final parsed = NotificationMarkers.parseMarkerBool(val);
      if (parsed) {
        hasChattingMarker.value = true;
      } else {
        // Only turn off if neither sub-source is unread
        if (!hasPrivateChatKey && !hasGroupChatKey) {
          hasGroupChatUnread.value = false;
          hasPrivateChatUnread.value = false;
          hasChattingMarker.value = false;
        } else {
          _syncChattingMarker();
        }
      }
    } else if (hasPrivateChatKey || hasGroupChatKey) {
      _syncChattingMarker();
    }
  }

  /// Update marker states from typed NotificationMarkers model
  void updateFromModel(NotificationMarkers? markers) {
    if (markers == null) return;
    hasCallingMarker.value = markers.calling;
    hasWalkieMarker.value = markers.walkie;

    if (markers.groupChat != null) {
      hasGroupChatUnread.value = markers.groupChat!;
    }
    if (markers.privateChat != null) {
      hasPrivateChatUnread.value = markers.privateChat!;
    }

    if (markers.chatting) {
      hasChattingMarker.value = true;
    } else {
      if (markers.groupChat == null && markers.privateChat == null) {
        hasGroupChatUnread.value = false;
        hasPrivateChatUnread.value = false;
        hasChattingMarker.value = false;
      } else {
        _syncChattingMarker();
      }
    }
  }

  void clearCallingMarker() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      hasCallingMarker.value = false;
    });
  }

  void clearChattingMarker() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      hasGroupChatUnread.value = false;
      hasPrivateChatUnread.value = false;
      hasChattingMarker.value = false;
    });
  }

  void clearWalkieMarker() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      hasWalkieMarker.value = false;
    });
  }

  void clearAll() {
    clearCallingMarker();
    clearChattingMarker();
    clearWalkieMarker();
  }
}
