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

  /// Optional live checks supplied by [ChatListController] when registered so
  /// stale backend heartbeats cannot turn off the dot while verified local
  /// unreads or manually-unread rows remain.
  bool Function()? hasLocalPrivateUnreadCheck;
  bool Function()? hasLocalGroupUnreadCheck;

  bool get _hasVerifiedLocalPrivateUnread =>
      hasLocalPrivateUnreadCheck?.call() ?? false;
  bool get _hasVerifiedLocalGroupUnread =>
      hasLocalGroupUnreadCheck?.call() ?? false;

  void _syncChattingMarker() {
    final next = hasGroupChatUnread.value || hasPrivateChatUnread.value;
    if (hasChattingMarker.value != next) {
      hasChattingMarker.value = next;
    }
  }

  void setPrivateChatUnread(bool hasUnread) {
    if (hasPrivateChatUnread.value != hasUnread) {
      hasPrivateChatUnread.value = hasUnread;
    }
    if (hasUnread) {
      if (!hasChattingMarker.value) hasChattingMarker.value = true;
    } else {
      _syncChattingMarker();
    }
  }

  void setGroupChatUnread(bool hasUnread) {
    if (hasGroupChatUnread.value != hasUnread) {
      hasGroupChatUnread.value = hasUnread;
    }
    if (hasUnread) {
      if (!hasChattingMarker.value) hasChattingMarker.value = true;
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
      final parsed = NotificationMarkers.parseMarkerBool(markers['calling']);
      if (hasCallingMarker.value != parsed) {
        hasCallingMarker.value = parsed;
      }
    }

    if (markers.containsKey('walkie')) {
      final val = markers['walkie'];
      final bool parsed;
      if (val is Map) {
        parsed = val['hasNotification'] == true ||
            val['isChannelSpeaking'] == true ||
            val['hasActiveTalk'] == true;
      } else {
        parsed = NotificationMarkers.parseMarkerBool(val);
      }
      if (hasWalkieMarker.value != parsed) {
        hasWalkieMarker.value = parsed;
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
      final parsed =
          NotificationMarkers.parseMarkerBool(val) ||
          _hasVerifiedLocalPrivateUnread;
      if (hasPrivateChatUnread.value != parsed) {
        hasPrivateChatUnread.value = parsed;
      }
    }

    final bool hasGroupChatKey = markers.containsKey('groupChat') ||
        markers.containsKey('group_chat') ||
        markers.containsKey('group');
    if (hasGroupChatKey) {
      final val = markers['groupChat'] ??
          markers['group_chat'] ??
          markers['group'];
      final parsed =
          NotificationMarkers.parseMarkerBool(val) ||
          _hasVerifiedLocalGroupUnread;
      if (hasGroupChatUnread.value != parsed) {
        hasGroupChatUnread.value = parsed;
      }
    }

    if (markers.containsKey('chatting') || markers.containsKey('chat')) {
      final val = markers['chatting'] ?? markers['chat'];
      final parsed = NotificationMarkers.parseMarkerBool(val);
      if (parsed) {
        if (!hasChattingMarker.value) hasChattingMarker.value = true;
      } else {
        // If neither private nor group chat keys are provided in this map:
        // Do NOT blindly wipe local unread chat states!
        // Local ChatListController maintains authoritative unread chat counts.
        if (!hasPrivateChatKey && !hasGroupChatKey) {
          final anyLocal = hasGroupChatUnread.value ||
              hasPrivateChatUnread.value ||
              _hasVerifiedLocalGroupUnread ||
              _hasVerifiedLocalPrivateUnread;
          if (!anyLocal) {
            if (hasChattingMarker.value) hasChattingMarker.value = false;
          } else {
            if (_hasVerifiedLocalGroupUnread && !hasGroupChatUnread.value) {
              hasGroupChatUnread.value = true;
            }
            if (_hasVerifiedLocalPrivateUnread && !hasPrivateChatUnread.value) {
              hasPrivateChatUnread.value = true;
            }
            // Keep chatting marker true because verified local unreads exist
            if (!hasChattingMarker.value) hasChattingMarker.value = true;
          }
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
    if (hasCallingMarker.value != markers.calling) {
      hasCallingMarker.value = markers.calling;
    }
    if (hasWalkieMarker.value != markers.walkie) {
      hasWalkieMarker.value = markers.walkie;
    }

    if (markers.groupChat != null) {
      final next = markers.groupChat! || _hasVerifiedLocalGroupUnread;
      if (hasGroupChatUnread.value != next) {
        hasGroupChatUnread.value = next;
      }
    }
    if (markers.privateChat != null) {
      final next = markers.privateChat! || _hasVerifiedLocalPrivateUnread;
      if (hasPrivateChatUnread.value != next) {
        hasPrivateChatUnread.value = next;
      }
    }

    if (markers.chatting) {
      if (!hasChattingMarker.value) hasChattingMarker.value = true;
    } else {
      if (markers.groupChat == null && markers.privateChat == null) {
        final anyLocal = hasGroupChatUnread.value ||
            hasPrivateChatUnread.value ||
            _hasVerifiedLocalGroupUnread ||
            _hasVerifiedLocalPrivateUnread;
        if (!anyLocal) {
          if (hasChattingMarker.value) hasChattingMarker.value = false;
        } else {
          if (_hasVerifiedLocalGroupUnread && !hasGroupChatUnread.value) {
            hasGroupChatUnread.value = true;
          }
          if (_hasVerifiedLocalPrivateUnread && !hasPrivateChatUnread.value) {
            hasPrivateChatUnread.value = true;
          }
          if (!hasChattingMarker.value) hasChattingMarker.value = true;
        }
      } else {
        _syncChattingMarker();
      }
    }
  }

  void clearCallingMarker() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasCallingMarker.value) hasCallingMarker.value = false;
    });
  }

  void clearChattingMarker() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasGroupChatUnread.value) hasGroupChatUnread.value = false;
      if (hasPrivateChatUnread.value) hasPrivateChatUnread.value = false;
      if (hasChattingMarker.value) hasChattingMarker.value = false;
    });
  }

  void clearWalkieMarker() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasWalkieMarker.value) hasWalkieMarker.value = false;
    });
  }

  void clearAll() {
    clearCallingMarker();
    clearChattingMarker();
    clearWalkieMarker();
  }
}
