import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'package:fgtracker/app/Core/values/bottomSheet.dart'; // ✅ ADD THIS
import 'package:fgtracker/app/Core/values/utility.dart'; // ✅ ADD THIS
import 'package:fgtracker/app/Data/Repositories/Auth_repo.dart';
import 'package:fgtracker/app/Model/ProfileRes.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Data/Repositories/Profile_Repo.dart';

class RegistrationController extends GetxController {
  var isLoading = false.obs;
  var isChecked = false.obs;
  var selectedImage = ''.obs;
  var gender = "".obs;
  var phoneNumber = ''.obs;
  var phoneError = ''.obs;

  final registerKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  UserData userData = UserData();
  Map<String, dynamic>? arguments = Get.arguments;

  @override
  void onInit() {
    super.onInit();

    if (arguments?['type'] == "Update") {
      userData = arguments?['userData'];
      nameController.text =
      userData.name == null ? "" : userData.name.toString();
      phoneController.text =
      userData.mobileNo == null ? "" : userData.mobileNo.toString();
      gender.value = userData.gender.toString() == ""
          ? "others"
          : userData.gender.toString();
    } else {
      phoneController.text = arguments?['mobNo'] ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // ✅ FIXED: ModalImage is used as a class, not a parameter type
  void pickImage(BuildContext context) {
    ModalImage bottomNavbar = ModalImage(
      isImageCroppable: true,
      onImageSelect: (path) async {
        if (Utility.isNotNullEmptyOrFalse(path)) {
          selectedImage.value = path;
          Navigator.pop(context);
        }
      },
    );
    bottomNavbar.mainBottomSheet(context);
  }

  Future<void> register(RegistrationController controller) async {
    if (registerKey.currentState!.validate()) {
      try {
        if (controller.selectedImage.value == '') {
          CommonDialog.errorMessage("Profile image can't be empty");
          return;
        }
        if (controller.gender.value == "") {
          CommonDialog.errorMessage("Please select your gender");
          return;
        }

        Loading().showloading();
        var result = await AuthRepo.Register(controller);
        if (result.status == true) {
          Global.storageServices.setString(PrefConst.isRegistered, "true");
          _fetchAndSaveProfile(result.message.toString());
        } else {
          Loading().dismissloading();
          CommonDialog.errorMessage(result.message);
        }
      } catch (e) {
        Loading().dismissloading();
        CommonDialog.errorMessage(e.toString());
      }
    }
  }

  Future<void> updateProfile(RegistrationController controller) async {
    if (registerKey.currentState!.validate()) {
      try {
        Loading().showloading();
        var result = await AuthRepo.updateProfile(controller);
        if (result.status == true) {
          _fetchAndSaveProfile(result.message.toString());
        } else {
          Loading().dismissloading();
          CommonDialog.errorMessage(result.message);
        }
      } catch (e) {
        Loading().dismissloading();
        CommonDialog.errorMessage(e.toString());
      }
    }
  }

  Future<void> _fetchAndSaveProfile(String successMessage) async {
    try {
      var profileData = await ProfileRepo.getProfileData();
      if (profileData.status == true) {
        Loading().dismissloading();
        Global.storageServices.setString(
          PrefConst.userName,
          profileData.data!.name ?? "Unknown",
        );
        Global.storageServices.setString(
          PrefConst.profileImage,
          profileData.data!.profileImage ?? "Unknown",
        );

        Utils().fluttertoast(successMessage);
        Get.offAllNamed(Routes.Home_Screen);
      } else {
        Loading().dismissloading();
        CommonDialog.errorMessage(profileData.message);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
    }
  }
}