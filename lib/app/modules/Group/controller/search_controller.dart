import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';
import 'package:fgtracker/app/Data/Services/LocationPermission.dart';
import 'package:fgtracker/app/Data/Services/contact_services.dart';
import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:fgtracker/app/modules/Group/controller/Group_Controller.dart';
import 'package:fgtracker/app/modules/Group/controller/MemberController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

class SearchUserController extends GetxController {
  final ContactService _contactService = ContactService();

  RxBool contactLoading = false.obs;
  RxBool isSearching = false.obs;

  var allUserProfileData = <UserListData>[].obs;
  var filteredUsers = <UserListData>[].obs;

  var responseError = "".obs;

  TextEditingController searchValues = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getRegisteredContacts();
  }

  Future<void> getRegisteredContacts() async {
    try {
      contactLoading.value = true;
      responseError.value = "";


      final contactNumbers = await _contactService.getMobileNumbers();

      if (contactNumbers.isEmpty) {
        allUserProfileData.clear();
        filteredUsers.clear();
        responseError.value = "No contacts found";
        return;
      }


      final result = await GroupRepo.getAllUserData();

      if (result.status == true) {
        final users = result.userData ?? [];

        final contactNumberSet = contactNumbers.toSet();

        final matchedUsers = users.where((user) {
          String mobileNo = (user.mobileNo ?? '').replaceAll(
            RegExp(r'[^0-9]'),
            '',
          );

          if (mobileNo.startsWith('91') && mobileNo.length > 10) {
            mobileNo = mobileNo.substring(2);
          }

          if (mobileNo.length > 10) {
            mobileNo = mobileNo.substring(
              mobileNo.length - 10,
            );
          }


          return contactNumberSet.contains(mobileNo);
        }).toList();


        allUserProfileData.value = matchedUsers;


        filteredUsers.value = matchedUsers;
      } else {
        responseError.value = result.message ?? "Something went wrong";
      }
    } catch (e) {
      responseError.value = e.toString();
    } finally {
      contactLoading.value = false;
    }
  }

  void filterUsers(String value) {
    value = value.trim().toLowerCase();

    if (value.isEmpty) {
      filteredUsers.value = allUserProfileData;
      return;
    }

    filteredUsers.value = allUserProfileData.where((user) {
      final name = (user.name ?? '').toLowerCase();


      final mobile = (user.mobileNo ?? '').toLowerCase();

      return name.contains(value) || mobile.contains(value);
    }).toList();
  }

  void clearSearch() {
    searchValues.clear();
    filteredUsers.value = allUserProfileData;
  }

  Future<void> refreshContacts() async {
    await getRegisteredContacts();
  }

  Future<bool> joinGroup(
    BuildContext context, {
    required MemberController controller,
    required String groupCode,
    required String groupId,
    required String userId,
    bool validateForm = true,
    String? type,
  }) async {
    final hasPermission =
        await LocationPermissions().handleLocationPermission();
    if (!hasPermission) {
      CommonDialog.errorMessage(
          "Location permission is required to join a group.");
      return false;
    }

    final location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        CommonDialog.errorMessage(
            "Please enable location services to join a group.");
        return false;
      }
    }

    try {
      Loading().showloading();
      final param = {
        "groupCode": groupCode,
        "userId": userId,
      };
      final result = await GroupRepo.joinGroup(url: "joingGroupMember",param);
      Loading().dismissloading();

      if (result.status == true) {
        Utils().fluttertoast(result.message.toString());
        controller.getMembersData(groupId);

        return true;
      } else {
        CommonDialog.errorMessage(result.message);
        return false;
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
      return false;
    }
  }
}
