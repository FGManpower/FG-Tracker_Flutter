import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Core/constant/pref_res.dart';
import '../../../Core/values/global.dart';
import '../../../Core/values/utility.dart';
import '../../../routes/app_pages.dart';
import '../../../Core/global/launchedFromCall.dart';
import '../../../modules/AppUpdate/Controller/UpdateCubit/update_cubit.dart';

class InitiateController extends GetxController
    with GetTickerProviderStateMixin {
  final UpdateCubit updateCubit = UpdateCubit();

  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  Timer? _splashTimer;

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

    if (CallSessionState.launchedFromCall || CallSessionState.isCallActive) {
      return;
    }

    _splashTimer = Timer(
      const Duration(seconds: 4),
      () => checkLoginStatus(),
    );
  }

  void checkLoginStatus() async {
    if (CallSessionState.isCallActive || CallSessionState.launchedFromCall) {
      return;
    }

    await Future.delayed(const Duration(seconds: 1));

    if (Utility.isNotNullEmptyOrFalse(
            Global.storageServices.getaccesstoken()) &&
        Utility.isNotNullEmptyOrFalse(
            Global.storageServices.get(PrefConst.isRegistered))) {
      Get.offAllNamed(Routes.Home_Screen);
    } else {
      final introDone =
          await Global.storageServices.getBool(PrefConst.introStatus);

      if (introDone == true) {
        Get.offAllNamed(Routes.Login);
      } else {
        Get.offAllNamed(Routes.Intro);
      }
    }
  }

  @override
  void onClose() {
    _splashTimer?.cancel();
    animationController.dispose();
    super.onClose();
  }
}
