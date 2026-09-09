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
  Map<String, dynamic>? get arguments =>
      Get.arguments is Map ? (Get.arguments as Map).cast<String, dynamic>() : _arguments;
  Map<String, dynamic>? _arguments;

  @override
  void onInit() {
    super.onInit();
    _arguments = Get.arguments is Map ? (Get.arguments as Map).cast<String, dynamic>() : null;
    initFields();
  }

  @override
  void onReady() {
    super.onReady();
    final args = arguments;
    if (args?['type'] == "Update" || (Get.arguments is Map && (Get.arguments as Map)['type'] == "Update")) {
      _fetchLatestProfileForEdit();
    }
  }

  void initFields() {
    final args = arguments;
    final bool isUpdate = args?['type'] == "Update" ||
        (Get.arguments is Map && (Get.arguments as Map)['type'] == "Update");

    if (isUpdate) {
      if (args?['userData'] is UserData) {
        userData = args!['userData'];
      } else if (Get.arguments is Map && (Get.arguments as Map)['userData'] is UserData) {
        userData = (Get.arguments as Map)['userData'];
      }

      // 1. Full Name (Pre-filled from backend UserData, then storage)
      final name = (userData.name != null && userData.name!.isNotEmpty)
          ? userData.name!
          : (Global.storageServices.get(PrefConst.userName)?.toString() ?? "");
      if (name.isNotEmpty) nameController.text = name;

      // 2. Phone Number (Pre-filled from backend UserData, then storage, then args)
      final phone = (userData.mobileNo != null && userData.mobileNo!.isNotEmpty)
          ? userData.mobileNo!
          : (Global.storageServices.get(PrefConst.userPhone)?.toString() ??
              args?['mobNo']?.toString() ??
              "");
      if (phone.isNotEmpty) phoneController.text = phone;

      // 3. Email Address (Pre-filled directly from backend UserData, storage, or args)
      final email = (userData.email != null && userData.email!.isNotEmpty)
          ? userData.email!
          : (Global.storageServices.get(PrefConst.userEmail)?.toString() ??
              args?['email']?.toString() ??
              "");
      if (email.isNotEmpty) emailController.text = email;

      // 4. Gender
      if (userData.gender != null && userData.gender.toString().isNotEmpty) {
        gender.value = userData.gender.toString();
      } else {
        gender.value = "male";
      }

      // Always fetch fresh backend profile directly via /getProfile API
      _fetchLatestProfileForEdit();
    } else {
      // Registration Mode
      final phone = args?['mobNo']?.toString() ??
          Global.storageServices.get(PrefConst.userPhone)?.toString() ??
          '';
      if (phone.isNotEmpty) phoneController.text = phone;

      final savedEmail = Global.storageServices.get(PrefConst.userEmail)?.toString() ?? '';
      if (savedEmail.isNotEmpty && emailController.text.isEmpty) {
        emailController.text = savedEmail;
      }
    }
  }

  Future<void> _fetchLatestProfileForEdit() async {
    try {
      var res = await ProfileRepo.getProfileData();
      if (res.status == true && res.data != null) {
        userData = res.data!;
        if (res.data!.email != null && res.data!.email!.isNotEmpty) {
          emailController.text = res.data!.email!;
          Global.storageServices.setString(PrefConst.userEmail, res.data!.email!);
        }
        if (res.data!.name != null && res.data!.name!.isNotEmpty) {
          nameController.text = res.data!.name!;
          Global.storageServices.setString(PrefConst.userName, res.data!.name!);
        }
        if (res.data!.mobileNo != null && res.data!.mobileNo!.isNotEmpty) {
          phoneController.text = res.data!.mobileNo!;
          Global.storageServices.setString(PrefConst.userPhone, res.data!.mobileNo!);
        }
        if (res.data!.gender != null && res.data!.gender.toString().isNotEmpty) {
          gender.value = res.data!.gender.toString();
        }
      }
    } catch (_) {}
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
          if (controller.emailController.text.trim().isNotEmpty) {
            Global.storageServices.setString(
              PrefConst.userEmail,
              controller.emailController.text.trim(),
            );
          }
          if (controller.phoneController.text.trim().isNotEmpty) {
            Global.storageServices.setString(
              PrefConst.userPhone,
              controller.phoneController.text.trim(),
            );
          }
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
          if (controller.emailController.text.trim().isNotEmpty) {
            Global.storageServices.setString(
              PrefConst.userEmail,
              controller.emailController.text.trim(),
            );
          }
          if (controller.phoneController.text.trim().isNotEmpty) {
            Global.storageServices.setString(
              PrefConst.userPhone,
              controller.phoneController.text.trim(),
            );
          }
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
        if (profileData.data?.email != null && profileData.data!.email!.isNotEmpty) {
          Global.storageServices.setString(
            PrefConst.userEmail,
            profileData.data!.email!,
          );
        }
        if (profileData.data?.mobileNo != null && profileData.data!.mobileNo!.isNotEmpty) {
          Global.storageServices.setString(
            PrefConst.userPhone,
            profileData.data!.mobileNo!,
          );
        }

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