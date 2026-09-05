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
  String selectedDialCode = '+91';

  final mobileErrorText = ''.obs;
  late FocusNode phoneFocusNode;

  void checkAndDismissKeyboard(String value) {
    mobileErrorText.value = '';
    if (selectedDialCode == '+91' && value.trim().length >= 10) {
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
        "MobileNo": mobNoController.text,
        "countryCode": selectedDialCode,
      };

      var result = await AuthRepo.login(param);
      if (result.status == true) {
        Loading().dismissloading();

        Get.toNamed(Routes.OTPScreen, arguments: {
          "mobNo": mobNoController.text,
          "countryCode": selectedDialCode,
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