import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';

import 'package:fgtracker/app/Model/MemberDataRes.dart';
import 'package:fgtracker/app/modules/Track/Controller/TrackController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';


class MemberController extends GetxController {
  RxBool memberDataLoading = false.obs;
  var memberData = <MemberData>[].obs;
  var responseError = "".obs;
  Map<String, dynamic>? arguments = Get.arguments;

  @override
  void onInit() {
    super.onInit();
    getMembersData(arguments?['groupId']);
  }

  Future<void> getMembersData(String groupId) async {
    try {
      memberDataLoading.value = true;
      var result = await GroupRepo.getMemberData(groupId);
      if (result.status == true) {
        memberData.value = result.memberData!;
        responseError.value = "";
        memberDataLoading.value = false;
      } else {
        memberDataLoading.value = false;
        responseError.value = result.message.toString();
      }
    } catch (e) {
      responseError.value = e.toString();
      memberDataLoading.value = false;
    }
  }

  Future<void> exitGroup(
    BuildContext context, {
    required String groupId,
  }) async {
    try {
      Loading().showloading();
      dynamic param = {
        "groupId": groupId,
      };
      var result = await GroupRepo.exitGroups(param);
      if (result.status == true) {
        Loading().dismissloading();
        leaveGroup(context, groupId: groupId);
      } else {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
    }
  }

  Future<void> deleteGroup(
    BuildContext context, {
    required String groupId,
  }) async {
    try {
      Loading().showloading();
      dynamic param = {
        "groupId": groupId,
      };
      var result = await GroupRepo.deleteGroups(param);
      if (result.status == true) {
        Loading().dismissloading();
        deleteGroupSocket(context, groupId: groupId);
      } else {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
    }
  }

  void leaveGroup(
    BuildContext context, {
    required String groupId,
  }) async {
    TrackingController.instance.exitGroup(
      groupId: groupId,
      onCompletion: (success) {
        if (success) {
          Utils().fluttertoast("Group Exit successfully");
          Get.offAllNamed(Routes.Home_Screen);
        }
      },
    );
  }

  void deleteGroupSocket(
    BuildContext context, {
    required String groupId,
  }) async {
    TrackingController.instance.deleteGroup(
      groupId: groupId,
      onCompletion: (success) {
        if (success) {
          Utils().fluttertoast("Group deleted successfully");
          Get.offAllNamed(Routes.Home_Screen);
        }
      },
    );
  }

}
