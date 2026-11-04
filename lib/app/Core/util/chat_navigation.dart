import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/Messages/Controller/GroupChatController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/MessageController.dart';
import 'package:fgtracker/app/modules/Messages/Controller/chat_list_controller.dart';
import 'package:fgtracker/app/Core/util/rt_log.dart';
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
    final peer = _peerId(arguments['userData']);

    // Auto-resolve chatId from ChatListController if caller didn't supply it (e.g. from Group member list)
    if ((arguments['chatId'] == null ||
            arguments['chatId'].toString().isEmpty ||
            arguments['chatId'].toString() == 'null') &&
        peer != null &&
        Get.isRegistered<ChatListController>()) {
      final existing =
          Get.find<ChatListController>().findPrivateChatByUserId(peer);
      final resolved =
          existing?.chatId ?? existing?.conversationId ?? existing?.id;
      if (resolved != null && resolved.toString().isNotEmpty) {
        arguments['chatId'] = resolved.toString();
      }
    }

    ChatDiagnosticLogger.logEvent(
      category: 'NAV',
      action: 'openPrivateChat',
      details: {
        'peer': peer,
        'chatId': arguments['chatId']?.toString(),
        'source': arguments['source'] ?? arguments['type'] ?? 'unknown',
      },
    );

    if (Get.currentRoute == Routes.chatScreen &&
        Get.isRegistered<MessageController>()) {
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
    if (userData == null) return null;
    if (userData is MemberData) return userData.userId?.toString();
    if (userData is Map) {
      return (userData['userId'] ?? userData['_id'] ?? userData['id'])?.toString();
    }
    try {
      final dynamic uid = (userData as dynamic).userId ?? (userData as dynamic).id;
      if (uid != null) return uid.toString();
    } catch (_) {}
    return null;
  }
}
