import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/Utils.dart';
import 'package:fgtracker/app/Core/values/global.dart';

import 'package:fgtracker/app/Core/values/loading.dart';
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

  //----------------- update ------------------ //

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
      phoneController.text = arguments?['mobNo'];
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    phoneController.dispose();
  }

  Future<void> register(RegistrationController controller) async {
    if (registerKey.currentState!.validate()) {
      try {
        if (controller.selectedImage.value == '') {
          CommonDialog.errorMessage("Profile image can't be empty");
          return;
        }
        if (controller.gender.value == "") {
          CommonDialog.errorMessage("please select the gender");
          return;
        }


        Loading().showloading();

        var result = await AuthRepo.Register(controller);
        if (result.status == true) {


          Global.storageServices.setString(
            PrefConst.isRegistered,
            "true",
          );

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


              Utils().fluttertoast(result.message.toString());
              Get.offAllNamed(Routes.Home_Screen);

            }else{
              Loading().dismissloading();
              CommonDialog.errorMessage(result.message);
            }
          } catch (e) {
            Loading().dismissloading();
            CommonDialog.errorMessage(result.message);
          }


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
          // Loading().dismissloading();
          // Utils().fluttertoast(result.message.toString());
          // Get.offAllNamed(Routes.Home_Screen);
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


              Utils().fluttertoast(result.message.toString());
              Get.offAllNamed(Routes.Home_Screen);

            }else{
              Loading().dismissloading();
              CommonDialog.errorMessage(result.message);
            }
          } catch (e) {
            Loading().dismissloading();
            CommonDialog.errorMessage(result.message);
          }

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


}
