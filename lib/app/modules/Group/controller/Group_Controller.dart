import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'dart:async';

import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Services/app_cache.dart';
import 'package:fgtracker/app/modules/Group/controller/MemberController.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fgtracker/l10n/l10n.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

import '../../Messages/Controller/GroupChatController.dart';
import '../../Messages/Controller/group_profile_details_controller.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Message_Services.dart';

class GroupController extends GetxController {
  GlobalKey<FormState> createGroupKey = GlobalKey<FormState>();
  final groupName = TextEditingController();
  final groupDesc = TextEditingController();
  RxBool groupDataLoading = false.obs;
  var groupData = <GroupsResData>[].obs;
  var responseError = "".obs;

  // ---- App cache (doc 07): last groups list shown at once ----

  /// The last refresh failed / timed out while groups are shown:
  /// "Couldn't refresh · Retry" instead of replacing the list with an error.
  final RxBool refreshFailed = false.obs;
  bool _cacheReadDone = false;
  AppCachePerf? _perf;

  @override
  void onInit() {
    super.onInit();
    _perf = AppCachePerf('groups')..mark('open');
    _showCachedGroups();
    ever<List<GroupsResData>>(groupData, (_) => _scheduleGroupsCacheSave());
  }

  /// Display only: `isCreator` / `isActive` from the cache never allow an
  /// action by themselves; every action is checked by the server.
  Future<void> _showCachedGroups() async {
    try {
      final cached = await AppCache.readAs(
          AppCache.groups, (m) => GroupsResData.fromJson(m));
      if (isClosed || cached.isEmpty) return;
      // An API / socket result that is already here wins (R3).
      final merged = AppCache.mergeCachedIntoLive<GroupsResData>(
        live: groupData,
        cached: cached,
        keyOf: (g) => g.id?.toString(),
      );
      if (groupData.isEmpty) {
        groupData.assignAll(merged);
        // The API failed before the cache was read: groups are on screen
        // now, so a small retry bar instead of the full error view.
        if (responseError.value.isNotEmpty) {
          responseError.value = '';
          refreshFailed.value = true;
        }
      }
      _perf?.mark('cache shown', extra: '${cached.length} groups');
    } catch (_) {
    } finally {
      _cacheReadDone = true;
    }
  }

  void _scheduleGroupsCacheSave() {
    if (!_cacheReadDone || isClosed) return;
    AppCache.scheduleWrite(
      AppCache.groups,
      () => [for (final g in groupData) g.toJson()],
    );
  }

  final Rxn<XFile> selectedGroupImage = Rxn<XFile>();
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> decodeQRCodeFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final barcodeScanner = BarcodeScanner();

      final barcodes = await barcodeScanner.processImage(inputImage);
      for (final barcode in barcodes) {
        final groupCode = barcode.rawValue;
        if (groupCode != null) {
          handleJoinGroup(groupCode);
        }
      }
      await barcodeScanner.close();
    }
  }

  void handleJoinGroup(String groupCode) {}

  Future<bool> createGroup(BuildContext context,
      {required GroupController controller}) async {
    if (!createGroupKey.currentState!.validate()) return false;
    try {
      Loading().showloading();
      dynamic param = {
        "groupName": groupName.text,
        "groupDesc": groupDesc.text,
      };
      final result = await GroupRepo.createGroup(
        param,
        imagePath: selectedGroupImage.value?.path,
      );      if (result.status == true) {
        Loading().dismissloading();
        // Success feedback: GroupMembershipSheet, shown by the caller.

        controller.getGroupData();

        return true;
      } else {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message);
        return false;
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
      return false;
    }
  }


  Future<void> updateGroupDetail({required String groupId}) async {
    CommonDialog.ConfirmationDialog(
      title: appL10n.group_updateGroupTitle,
      content: appL10n.group_updateGroupConfirm,
      cancel: appL10n.common_no,
      confirm: appL10n.common_yes,
      icon: Icons.edit_rounded,
      onCancel: () {
        Get.back();
      },
      onConfirm: () {
        Get.back();
        _performUpdateGroupDetail(groupId: groupId);
      },
    );
  }

  Future<bool> updateOnlyAdminsCanSend({
    required String groupId,
    required bool onlyAdminsCanSend,
  }) async {
    try {
      Loading().showloading();
      final param = {
        "groupId": groupId,
        "onlyAdminsCanSend": onlyAdminsCanSend,
      };

      final result = await GroupRepo.updateGroup(param);
      Loading().dismissloading();

      if (result.status == true) {
        if (Get.isRegistered<GroupMessageController>()) {
          final chatController = Get.find<GroupMessageController>();
          chatController.onlyAdminsCanSend.value = onlyAdminsCanSend;
        }

        Utils().fluttertoast(onlyAdminsCanSend
            ? appL10n.groupAdmin_onlyAdminsNowToast
            : appL10n.groupAdmin_allParticipantsNowToast);

        _refreshGroupProfile(groupId);
        return true;
      } else {
        Utils().fluttertoast(result.message ?? appL10n.groupAdmin_updateSettingFailed);
        return false;
      }
    } catch (e) {
      Loading().dismissloading();
      Utils().fluttertoast(appL10n.groupAdmin_updateSettingFailed);
      return false;
    }
  }

  Future<void> _performUpdateGroupDetail({
    required String groupId,
  }) async {
    try {
      Loading().showloading();
      final param = {
        "groupName": groupName.text.trim(),
        "groupDesc": groupDesc.text.trim(),
        "groupId": groupId,
      };

      final result = await GroupRepo.updateGroup(
        param,
        imagePath: selectedGroupImage.value?.path,
      );

      Loading().dismissloading();

      if (result.status == true) {
        selectedGroupImage.value = null;

        if (Get.isRegistered<GroupMessageController>()) {
          final chatController = Get.find<GroupMessageController>();
          chatController.groupName.value = groupName.text.trim();
          // Keep description in sync so Group Profile shows it right away
          chatController.groupDesc.value = groupDesc.text.trim();
          chatController.getGroupMessages();
        }

        Get.back();
        Utils().fluttertoast(result.message.toString());

        // Refresh Group Profile screen so new name / image show right away
        _refreshGroupProfile(groupId);
        // Refresh All Groups list too (no skeleton loader)
        _refreshGroupListSilently();
      } else {
        Utils().fluttertoast(result.message.toString());
      }
    } catch (e) {
      Loading().dismissloading();
      Utils().fluttertoast(e.toString());
    }
  }

  Future<void> _refreshGroupProfile(String groupId) async {
    final int? gId = int.tryParse(groupId);
    if (gId == null || !Get.isRegistered<GroupProfileDetailsController>()) {
      return;
    }
    final profileController = Get.find<GroupProfileDetailsController>();
    await profileController.fetchProfileDetails(gId, silent: true);

    // Keep the open group chat header image in sync too
    final String? newImage = profileController.profileData.value?.group?.groupProfile;
    if (newImage != null && Get.isRegistered<GroupMessageController>()) {
      Get.find<GroupMessageController>().groupImage = newImage;
    }
  }

  /// Refresh All Groups list without the skeleton loader
  Future<void> refreshGroupListSilently() => _refreshGroupListSilently();

  Future<void> _refreshGroupListSilently() async {
    try {
      final result = await GroupRepo.getGroupData();
      if (result.status != true || result.data?.groupData == null) return;
      // Update the registered instance (used by All Groups screen) and this one
      final targets = <GroupController>{this};
      if (Get.isRegistered<GroupController>()) {
        targets.add(Get.find<GroupController>());
      }
      for (final c in targets) {
        c.groupData.value = result.data!.groupData!;
      }
    } catch (_) {
      // Keep the current list if the refresh fails
    }
  }

  Future<void> getGroupData({String? type}) async {
    try {
      groupDataLoading.value = true;
      var result = await GroupRepo.getGroupData()
          .timeout(const Duration(seconds: 10)); // never an endless loader
      if (result.status == true) {
        final list = result.data?.groupData ?? <GroupsResData>[];
        groupData.value = list;
        responseError.value = "";
        refreshFailed.value = false;
        groupDataLoading.value = false;
        _perf?.mark('API done', extra: '${list.length} groups');
        _perf?.markAfterFrame('rendered');
        // The server confirms "no groups" (e.g. the last one was left):
        // drop the saved copy, so it never comes back as a ghost (R5).
        if (list.isEmpty) unawaited(AppCache.clearArea(AppCache.groups));
      } else {
        groupDataLoading.value = false;
        _onGroupLoadFailed(result.message.toString());
      }
    } catch (e) {
      groupDataLoading.value = false;
      _onGroupLoadFailed(e.toString());
    }
  }

  /// Groups on screen (cached or earlier) stay, with a small retry bar;
  /// only an empty screen gets the full error view (as before).
  void _onGroupLoadFailed(String message) {
    if (groupData.isNotEmpty) {
      refreshFailed.value = true;
    } else {
      responseError.value = message;
    }
  }

  Future<void> updateGroup(GroupController controller,
      {required String groupId, required String groupStatus}) async {
    final bool newActiveState = groupStatus.toLowerCase() == "true" ||
        groupStatus == "1" ||
        groupStatus.toLowerCase() == "active";

    // Optimistically update the in-memory group state so the switch reflects immediately
    final targetIndex = groupData.indexWhere((g) => g.id?.toString() == groupId);
    final previousState = targetIndex != -1 ? groupData[targetIndex].isActive : null;
    if (targetIndex != -1) {
      groupData[targetIndex].isActive = newActiveState;
      groupData.refresh();
    }

    try {
      Loading().showloading();
      final dynamic param = {
        "groupId": groupId.toString(),
        "isActiveGroup": groupStatus.toString(),
      };

      final result = await GroupRepo.updateGroupStatus(param);
      Loading().dismissloading();

      if (result.isSuccess || result.status == true) {
        // Sync local socket service deactivated map
        SocketMessageService.instance.groupDeactivated[groupId] = !newActiveState;

        final toastMsg = (result.message != null && result.message!.trim().isNotEmpty)
            ? result.message!
            : (newActiveState
                ? appL10n.group_activatedSuccess
                : appL10n.group_deactivatedSuccess);
        Utils().fluttertoast(toastMsg);

        controller.getGroupData();
      } else {
        // Revert optimistic update on failure
        if (targetIndex != -1 && previousState != null) {
          groupData[targetIndex].isActive = previousState;
          groupData.refresh();
        }
        CommonDialog.errorMessage(result.message ?? appL10n.group_statusUpdateFailed);
      }
    } catch (e) {
      Loading().dismissloading();
      // Revert optimistic update on error
      if (targetIndex != -1 && previousState != null) {
        groupData[targetIndex].isActive = previousState;
        groupData.refresh();
      }
      CommonDialog.errorMessage(e.toString());
    }
  }

  Future<void> deleteGroupMember(
    BuildContext context, {
    required String groupId,
    required String groupMemberId,
    required void Function(bool) onSuccess,
  }) async {
    try {
      Loading().showloading();

      final dynamic param = {
        "groupId": groupId,
        "groupMemberId": groupMemberId,
      };

      final result = await GroupRepo.deleteGroupsMember(param);

      Loading().dismissloading();

      if (result.status == true) {
        onSuccess(true);
      } else {
        CommonDialog.errorMessage(result.message);
        onSuccess(false);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
      onSuccess(false);
    }
  }

  Future<void> addGroupMember(
    BuildContext context, {
    required String groupId,
    required String userId,
    required void Function(bool) onSuccess,
  }) async {
    try {
      Loading().showloading();

      final dynamic param = {
        "groupId": groupId,
        "userId": userId,
      };

      final result = await GroupRepo.addGroupMember(param);

      Loading().dismissloading();

      if (result.status == true) {
        Utils().fluttertoast(result.message ?? appL10n.groupAdmin_memberAdded);
        onSuccess(true);
      } else {
        CommonDialog.errorMessage(result.message);
        onSuccess(false);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
      onSuccess(false);
    }
  }

  Future<void> promoteAdmin(
    BuildContext context, {
    required String groupId,
    required String userId,
    required void Function(bool) onSuccess,
  }) async {
    try {
      Loading().showloading();

      final dynamic param = {
        "groupId": groupId,
        "userId": userId,
      };

      final result = await GroupRepo.promoteAdmin(param);

      Loading().dismissloading();

      if (result.status == true) {
        onSuccess(true);
      } else {
        CommonDialog.errorMessage(result.message);
        onSuccess(false);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
      onSuccess(false);
    }
  }

  Future<void> demoteAdmin(
    BuildContext context, {
    required String groupId,
    required String userId,
    required void Function(bool) onSuccess,
  }) async {
    try {
      Loading().showloading();

      final dynamic param = {
        "groupId": groupId,
        "userId": userId,
      };

      final result = await GroupRepo.demoteAdmin(param);

      Loading().dismissloading();

      if (result.status == true) {
        onSuccess(true);
      } else {
        CommonDialog.errorMessage(result.message);
        onSuccess(false);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
      onSuccess(false);
    }
  }

  Future<void> confirmAndExitGroup(
    BuildContext context, {
    required String groupId,
    required String groupName,
  }) async {
    Get.defaultDialog(
      title: appL10n.group_exitGroup,
      middleText: appL10n.group_exitGroupNamedConfirm(groupName),
      textCancel: appL10n.common_cancel,
      textConfirm: appL10n.common_exit,
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () async {
        Get.back();
        await exitGroup(groupId: groupId);
      },
    );
  }

  Future<void> exitGroup({required String groupId}) async {
    try {
      Loading().showloading();
      dynamic param = {
        "groupId": groupId,
        "userId": PrefConst.userId,
      };
      var result = await GroupRepo.exitGroups(param);
      if (result.status == true) {
        Loading().dismissloading();
      } else {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
    }
  }


  Future<void> pickGroupImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      selectedGroupImage.value = image;
    }
  }

  void removeSelectedGroupImage() {
    selectedGroupImage.value = null;
  }





}
