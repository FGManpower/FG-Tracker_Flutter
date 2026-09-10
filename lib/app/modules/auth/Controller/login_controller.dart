import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'package:fgtracker/app/Data/Repositories/Auth_repo.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Login_Controller extends GetxController {
  final mobNoController = TextEditingController();
  final loginKey = GlobalKey<FormState>();

  RxBool isLoading = false.obs;
  final selectedDialCode = '+91'.obs;

  final mobileErrorText = ''.obs;
  late FocusNode phoneFocusNode;

  void checkAndDismissKeyboard(String value) {
    if (mobileErrorText.value.isNotEmpty) {
      mobileErrorText.value = '';
    }
    if (selectedDialCode.value == '+91' && value.trim().length >= 10) {
      phoneFocusNode.unfocus();
    } else if (value.trim().length >= 12) {
      phoneFocusNode.unfocus();
    }
  }

  bool validateMobile() {
    String number = mobNoController.text.trim();

    if (number.isEmpty) {
      mobileErrorText.value = AppText.mobNOIsRqrd;
      return false;
    }

    if (selectedDialCode.value == '+91') {
      if (number.length != 10) {
        mobileErrorText.value = "Please enter a valid 10-digit mobile number";
        return false;
      }
    } else {
      if (number.length < 7 || number.length > 15) {
        mobileErrorText.value = "Please enter a valid mobile number";
        return false;
      }
    }

    mobileErrorText.value = '';
    return true;
  }

  Future<void> login() async {
    if (!validateMobile()) return;
    if (!loginKey.currentState!.validate()) return;

    await _performLogin();
  }

  Future<void> _performLogin() async {
    try {
      Loading().showloading();
      dynamic param = {
        "MobileNo": mobNoController.text.trim(),
        "countryCode": selectedDialCode.value,
      };

      var result = await AuthRepo.login(param);
      if (result.status == true) {
        Loading().dismissloading();

        Get.toNamed(Routes.OTPScreen, arguments: {
          "mobNo": mobNoController.text.trim(),
          "countryCode": selectedDialCode.value,
        });
      } else {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
    }
  }

  @override
  void onInit() {
    super.onInit();
    phoneFocusNode = FocusNode();
  }

  @override
  void dispose() {
    mobNoController.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }
}

class AuthController extends GetxController {
  var isAcceptedTerm = false.obs;

  void loadAcceptance(String phone) {
    String? val = Global.storageServices.get("${PrefConst.AcceptPolicy}_$phone");
    isAcceptedTerm.value = (val == "true");
  }

  void setAcceptance(String phone, bool value) {
    Global.storageServices.setString(
        "${PrefConst.AcceptPolicy}_$phone", value ? "true" : "false");
    isAcceptedTerm.value = value;
  }
}