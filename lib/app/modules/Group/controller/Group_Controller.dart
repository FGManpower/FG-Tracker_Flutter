import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/modules/Group/controller/MemberController.dart';
import 'package:fgtracker/app/Model/GroupRes.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

import '../../Messages/Controller/GroupChatController.dart';
import '../../Messages/Controller/group_profile_details_controller.dart';

class GroupController extends GetxController {
  GlobalKey<FormState> createGroupKey = GlobalKey<FormState>();
  final groupName = TextEditingController();
  final groupDesc = TextEditingController();
  RxBool groupDataLoading = false.obs;
  var groupData = <GroupsResData>[].obs;
  var responseError = "".obs;
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
        Utils().fluttertoast(result.message.toString());

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
      title: "Update Group",
      content: "Are you sure you want to update the group details?",
      cancel: "No",
      confirm: "Yes",
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
      var result = await GroupRepo.getGroupData();
      if (result.status == true) {
        groupData.value = result.data!.groupData!;
        responseError.value = "";
        groupDataLoading.value = false;
      } else {
        groupDataLoading.value = false;
        responseError.value = result.message.toString();
      }
    } catch (e) {
      responseError.value = e.toString();
      groupDataLoading.value = false;
    }
  }

  Future<void> updateGroup(GroupController controller,
      {required String groupId, required String groupStatus}) async {
    try {
      Loading().showloading();
      dynamic param = {
        "groupId": groupId,
        "isActiveGroup": groupStatus,
      };
      var result = await GroupRepo.updateGroupStatus(param);
      if (result.status == true) {
        Loading().dismissloading();
        Utils().fluttertoast(result.message.toString());
        controller.getGroupData();
      } else {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      Loading().dismissloading();
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

  Future<void> confirmAndExitGroup(
    BuildContext context, {
    required String groupId,
    required String groupName,
  }) async {
    Get.defaultDialog(
      title: "Exit Group",
      middleText:
          "Are you sure you want to exit \"$groupName\"? You'll need a group code to rejoin.",
      textCancel: "Cancel",
      textConfirm: "Exit",
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
