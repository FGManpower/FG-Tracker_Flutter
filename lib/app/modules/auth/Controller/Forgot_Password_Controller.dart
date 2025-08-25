import 'package:fgtracker/app/Core/values/Dialog/Common_dialog.dart';
import 'package:fgtracker/app/Core/values/loading.dart';
import 'package:fgtracker/app/Data/Repositories/Auth_repo.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final forgetKey = GlobalKey<FormState>();
  final resetKey = GlobalKey<FormState>();

  Future<void> forgetPassword() async {
    try {
      Loading().showloading();
      dynamic param = {
        "Email": emailController.text,
      };
      var result = await AuthRepo.forgetPassword(param);
      if (result.status == true) {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message, status: true);
      } else {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message);
      }
    } catch (e) {
      Loading().dismissloading();
      CommonDialog.errorMessage(e.toString());
    }
  }

  Future<void> resetPassword() async {
    try {
      Loading().showloading();
      dynamic param = {
        "newPassword": newPasswordController.text,
        "confirmPassword": confirmPasswordController.text,
      };
      var result = await AuthRepo.resetPassword(param);
      if (result.status == true) {
        Loading().dismissloading();
        CommonDialog.errorMessage(result.message, status: true);
        Get.offNamedUntil(Routes.Login, (route) => false);
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
