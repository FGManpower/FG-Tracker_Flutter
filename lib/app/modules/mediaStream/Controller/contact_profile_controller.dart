import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/constant/pref_res.dart';
import '../../../Core/values/Utils.dart';
import '../../../Core/values/global.dart';
import '../../../Data/Repositories/call_repo.dart';
import '../../../Data/Services/call_service.dart';
import '../../../Data/Services/group_call_service.dart';
import '../../../Model/CallDetail.dart';
import '../../../Model/MemberDataRes.dart';
import '../../../routes/app_pages.dart';
import '../../Messages/Controller/MessageController.dart';
import '../../Messages/Views/Chat_Screen.dart';

class ContactProfileController extends GetxController {
  final MemberData? contactData;
  final bool isGroup;
  final String? groupId;
  final String? groupName;
  final String? groupAvatar;
  final String? callId;

  ContactProfileController({
    this.contactData,
    this.isGroup = false,
    this.groupId,
    this.groupName,
    this.groupAvatar,
    this.callId,
  });

  var isLoading = true.obs;
  var errorMessage = ''.obs;
  final detail = Rxn<CallHistoryDetailData>();

  String get _targetGroupId {
    final String g = groupId?.toString().trim() ?? '';
    if (g.isNotEmpty) return g;
    return detail.value?.groupId?.toString().trim() ?? '';
  }

  /// participants + joinedMembers merge (duplicate hata ke).
  List<CallParticipant> get participants {
    final CallHistoryDetailData? d = detail.value;
    if (d == null) return [];
    final List<CallParticipant> out = [];
    final Set<String> seen = {};
    for (final p in [...?d.participants, ...?d.joinedMembers]) {
      final String key = (p.userId ?? p.id?.toString() ?? '').trim();
      if (key.isEmpty || seen.add(key)) out.add(p);
    }
    return out;
  }

  @override
  void onInit() {
    super.onInit();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    final String id = callId?.trim() ?? '';
    if (id.isEmpty) {
      errorMessage.value = "Call id not found";
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final CallHistoryDetailRes res = await CallRepo.getCallHistoryDetail(id);
      if (isClosed) return;
      if (res.status == true && res.data != null) {
        detail.value = res.data;
      } else {
        errorMessage.value = res.message ?? "Failed to load call detail";
      }
    } catch (e, st) {
      log("[ContactProfile] getCallHistoryDetail error: $e\n$st");
      if (!isClosed) errorMessage.value = "Something went wrong";
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void startCall(BuildContext context, {required bool isVideo}) {
    if (isGroup) {
      if (_targetGroupId.isNotEmpty) {
        GroupCallService.instance.startGroupCall(
          context,
          groupId: _targetGroupId,
          groupName: groupName ?? "Group Call",
          groupProfile: groupAvatar,
          isVideo: isVideo,
        );
      }
    } else {
      final String remoteId = contactData?.userId?.toString() ?? '';
      if (remoteId.isNotEmpty) {
        CallService().startCall(
          context,
          callerId: Global.storageServices.get(PrefConst.userId).toString(),
          remoteUserId: remoteId,
          is_video: isVideo,
          callerName: contactData?.name ?? 'User',
        );
      } else {
        Utils().fluttertoast("Unable to call this contact");
      }
    }
  }

  void openMessage() {
    if (isGroup) {
      if (_targetGroupId.isEmpty) return;
      Get.toNamed(
        Routes.groupChatScreen,
        arguments: {
          "groupId": _targetGroupId,
          "groupName": groupName ?? "Group",
          "groupProfile": groupAvatar,
        },
      );
    } else {
      final MemberData? user = contactData;

      if (user == null || user.userId == null) {
        Utils().fluttertoast("Unable to open chat for this contact");
        return;
      }

      log("========== OPEN PRIVATE CHAT FROM PROFILE ==========");
      log("CURRENT USER ID: ${Global.storageServices.get(PrefConst.userId)}");
      log("RECEIVER USER ID: ${user.userId}");
      log("RECEIVER NAME: ${user.name}");
      log("RECEIVER IMAGE: ${user.profileImage}");
      log("CHAT ID FROM CONTACT DATA: NOT AVAILABLE IN CURRENT CODE");

      Get.to(
            () => ChatScreen(),
        arguments: {
          "userData": MemberData(
            userId: user.userId,
            name: user.name,
            mobileNo: user.mobileNo,
            profileImage: user.profileImage,
            isOnline: user.isOnline,
            groupId: 0,
          ),
          "type": "chatScreen",
          "chatType": "private",
          "groupId": 0,
          "groupName": user.name ?? "Chat",
        },
        binding: BindingsBuilder(() {
          if (!Get.isRegistered<MessageController>()) {
            Get.put(MessageController());
            log("MessageController CREATED");
          } else {
            log("MessageController ALREADY REGISTERED");
          }
        }),
      );
    }
  }
}