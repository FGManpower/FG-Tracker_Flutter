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
    if (markers.containsKey('calling')) {
      hasCallingMarker.value = markers['calling'] == true;
    }
    if (markers.containsKey('chatting') || markers.containsKey('chat')) {
      hasChattingMarker.value =
          markers['chatting'] == true || markers['chat'] == true;
    }
    if (markers.containsKey('walkie')) {
      hasWalkieMarker.value = markers['walkie'] == true;
    }
  }

  /// Update marker states from typed NotificationMarkers model
  void updateFromModel(NotificationMarkers? markers) {
    if (markers == null) return;
    hasCallingMarker.value = markers.calling;
    hasChattingMarker.value = markers.chatting;
    hasWalkieMarker.value = markers.walkie;
  }

  void clearCallingMarker() => hasCallingMarker.value = false;
  void clearChattingMarker() => hasChattingMarker.value = false;
  void clearWalkieMarker() => hasWalkieMarker.value = false;
}
