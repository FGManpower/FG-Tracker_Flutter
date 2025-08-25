
import 'package:fgtracker/app/Core/util/http/Constant.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'global.dart';

class LogoutUser {
  logout() {
    Global.storageServices.remove(Constant.STORAGE_USER_TOKEN_KEY);
    Global.storageServices.remove(Constant.DEVICE_ID);
    Global.storageServices.remove(Constant.isRegistered);

    // Global.storageServices.remove("UserData");
    Get.offNamedUntil(Routes.Login, (route) => false);
  }
}
