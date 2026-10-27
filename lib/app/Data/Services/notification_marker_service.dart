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
      final val = markers['calling'];
      if (val is bool) {
        hasCallingMarker.value = val;
      } else if (val is Map) {
        hasCallingMarker.value =
            val['hasMissedCall'] == true || val['hasNotification'] == true;
      }
    }
    if (markers.containsKey('chatting') || markers.containsKey('chat')) {
      final val = markers['chatting'] ?? markers['chat'];
      if (val is bool) {
        hasChattingMarker.value = val;
      } else if (val is Map) {
        hasChattingMarker.value =
            val['hasUnread'] == true || val['hasNotification'] == true;
      }
    }
    if (markers.containsKey('walkie')) {
      final val = markers['walkie'];
      if (val is bool) {
        hasWalkieMarker.value = val;
      } else if (val is Map) {
        hasWalkieMarker.value = val['hasNotification'] == true ||
            val['isChannelSpeaking'] == true ||
            val['hasActiveTalk'] == true;
      }
    }
  }

  /// Update marker states from typed NotificationMarkers model
  void updateFromModel(NotificationMarkers? markers) {
    if (markers == null) return;
    hasCallingMarker.value = markers.calling;
    hasChattingMarker.value = markers.chatting;
    hasWalkieMarker.value = markers.walkie;
  }

  void clearCallingMarker() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      hasCallingMarker.value = false;
    });
  }

  void clearChattingMarker() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
