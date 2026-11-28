import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:get/get.dart';

/// Opens a chat from places that may themselves be on top of a chat screen
/// (forward, notification tap).
///
/// `Get.toNamed(Routes.chatScreen)` while a chat screen is showing was
/// ignored (`preventDuplicates`), and pushing it anyway would hand the new
/// page the OLD controller (the binding's untagged `lazyPut` returns the
/// registered instance). So: same chat -> stay; other chat -> close the
/// current chat screen first, let GetX dispose its controller, then open.
class ChatNavigation {
  ChatNavigation._();

  /// Slightly longer than the chat routes' 500 ms transition.
  static const Duration _disposeWait = Duration(milliseconds: 650);

  static Future<void> openPrivateChat(Map<String, dynamic> arguments) async {
    if (Get.currentRoute == Routes.chatScreen &&
        Get.isRegistered<MessageController>()) {
      final peer = _peerId(arguments['userData']);
      final current = Get.find<MessageController>();
      String? currentPeer;
      try {
        currentPeer = current.memberData.userId?.toString();
      } catch (_) {}
      if (peer != null && peer == currentPeer) return; // already open

      Get.until((route) => route.settings.name != Routes.chatScreen);
      await Future.delayed(_disposeWait);
      if (Get.isRegistered<MessageController>()) {
        await Get.delete<MessageController>(force: true);
      }
    }
    Get.toNamed(Routes.chatScreen, arguments: arguments);
  }

  static Future<void> openGroupChat(Map<String, dynamic> arguments) async {
    if (Get.currentRoute == Routes.groupChatScreen &&
        Get.isRegistered<GroupMessageController>()) {
      final target = arguments['groupId']?.toString();
      final current = Get.find<GroupMessageController>();
      String? currentGroup;
      try {
        currentGroup = current.groupId.toString();
      } catch (_) {}
      if (target != null && target == currentGroup) return; // already open

      Get.until((route) => route.settings.name != Routes.groupChatScreen);
      await Future.delayed(_disposeWait);
      if (Get.isRegistered<GroupMessageController>()) {
        await Get.delete<GroupMessageController>(force: true);
      }
    }
    Get.toNamed(Routes.groupChatScreen, arguments: arguments);
  }

  static String? _peerId(dynamic userData) {
    if (userData is MemberData) return userData.userId?.toString();
    if (userData is Map) return userData['userId']?.toString();
    return null;
  }
}
