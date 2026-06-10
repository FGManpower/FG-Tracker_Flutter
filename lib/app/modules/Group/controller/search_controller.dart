import 'package:fgtracker/app/Data/Repositories/GroupRepo.dart';

import 'package:fgtracker/app/Model/user_profileList_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchUserController extends GetxController {
  RxBool allUserDataLoading = false.obs;
  var allUserProfileData = <UserListData>[].obs;
  var responseError = "".obs;
  TextEditingController searchValues = TextEditingController();
  Future<void> getAllUserOrJoinGroup() async {
    try {
      allUserDataLoading.value = true;
      var result = await GroupRepo.getAllUserData();
      if (result.status == true) {
        allUserProfileData.value = result.userData ?? [];

        responseError.value = "";
        allUserDataLoading.value = false;
      } else {
        allUserDataLoading.value = false;
        responseError.value = result.message.toString();
      }
    } catch (e) {
      responseError.value = e.toString();
      allUserDataLoading.value = false;
    }
  }


  final filteredUsers = <UserListData>[].obs;




  void filterUsers(String value) {
    value = value.trim();

    if (value.length != 10) {
      filteredUsers.clear();
      return;
    }

    filteredUsers.value = allUserProfileData.where((user) {
      return (user.mobileNo ?? '').trim() == value;
    }).toList();
  }
  void clearSearch() {
    searchValues.clear();
    filteredUsers.value = allUserProfileData;
  }
}
