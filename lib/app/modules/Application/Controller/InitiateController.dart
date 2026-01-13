import 'dart:async';
import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/modules/AppUpdate/Controller/UpdateCubit/update_cubit.dart';
import 'package:fgtracker/app/modules/AppUpdate/Views/ShoreBird_AppUpdate_Screen.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

import '../../../Core/constant/notification_holder.dart';
import '../../../Core/values/Utils.dart';
import '../../../Data/Services/Custom_NotificationServices.dart';

class InitiateController extends GetxController with GetTickerProviderStateMixin {
  final UpdateCubit updateCubit = UpdateCubit();
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    animationController.forward();



    Timer(const Duration(seconds: 4), () => checkLoginStatus());
  }





  Future<void> checkAppUpdates() async {
    final isUpdateRequired = await updateCubit.checkForUpdate();
    if (!isUpdateRequired) {
      checkLoginStatus();
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAll(() => const ShorebirdAppUpdateScreen());
      });
    }
  }

  void checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1));
    if (Utility.isNotNullEmptyOrFalse(Global.storageServices.getaccesstoken()) &&
        Utility.isNotNullEmptyOrFalse(Global.storageServices.get(PrefConst.isRegistered))) {
      Get.offAllNamed(Routes.Home_Screen);
    } else {

      if(await Global.storageServices.getBool(PrefConst.introStatus)==true){
        Get.offAllNamed(Routes.Login);
      }else{
        Get.offAllNamed(Routes.Intro);
      }


    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
