import 'dart:developer';
import 'package:fgtracker/app/Core/values/Utils.dart';

import 'package:get/get.dart';

import '../../../Core/values/loading.dart';
import '../../../Core/values/logoutuser.dart';
import '../../../Data/Repositories/Auth_repo.dart';

class logOutController extends GetxController {
  Future<void> logOutUser() async {
    try {
      Loading().showloading();

      try {
        var result = await AuthRepo.logOutUser();
        if (result.message != null && result.message!.toString().trim().isNotEmpty) {
          Utils().fluttertoast(result.message.toString());
        }
      } catch (e) {
        log("logOutUser API error: $e");
      }
    } finally {
      Loading().dismissloading();
      await LogoutUser().logout();
    }
  }
}
