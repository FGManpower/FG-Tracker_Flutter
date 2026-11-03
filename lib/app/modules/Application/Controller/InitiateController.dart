import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../Core/constant/pref_res.dart';

import '../../../Core/values/global.dart';
import '../../../Core/values/utility.dart';
import '../../../Model/group_member_model.dart';
import '../../../routes/app_pages.dart';
import '../../../Core/global/launchedFromCall.dart';
import '../../../Core/constant/notification_holder.dart';
import 'package:fgtracker/app/Data/Services/Socket/Socket_Walkie-Talkie-Service.dart';
import '../../../modules/AppUpdate/Controller/UpdateCubit/update_cubit.dart';
import '../../../modules/Walkie-talkie/Services/walkie_notification_manager.dart';

class InitiateController extends GetxController
    with GetTickerProviderStateMixin {
  final UpdateCubit updateCubit = UpdateCubit();

  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> pulseAnimation;

  Timer? _splashTimer;

  bool get _isCallOrWalkieActive {
    return CallSessionState.launchedFromCall ||
        CallSessionState.isCallActive ||
        WalkieLaunchTracker.fromWalkieCall ||
        WalkieNotificationManager.instance.isWalkieScreenActive.value ||
        GroupWalkieService.instance.currentGroupId != null ||
        Get.currentRoute == Routes.groupWalkieScreen ||
        Get.currentRoute == Routes.callScreen ||
        Get.currentRoute == Routes.groupCallingScreen;
  }

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    scaleAnimation = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic),
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );

    animationController.forward();

    if (_isCallOrWalkieActive) {
      _splashTimer?.cancel();
      return;
    }

    Future.microtask(() async {
      // await CallKitService.instance.checkCallOnLaunch();

      if (_isCallOrWalkieActive) {
        _splashTimer?.cancel();
        return;
      }

      _splashTimer = Timer(
        const Duration(seconds: 4),
        () => checkLoginStatus(),
      );
    });
  }

  Future<bool> _isLocationReady() async {
    try {
      bool alwaysGranted;
      if (GetPlatform.isIOS) {
        alwaysGranted =
            await Geolocator.checkPermission() == LocationPermission.always;
      } else {
        final whenInUse = await Permission.locationWhenInUse.status;
        final always = await Permission.locationAlways.status;
        alwaysGranted = whenInUse.isGranted && always.isGranted;
      }
      if (!alwaysGranted) return false;
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  Future<void> checkLoginStatus() async {
    if (_isCallOrWalkieActive ||
        (Get.currentRoute.isNotEmpty && Get.currentRoute != Routes.Splash)) {
      _splashTimer?.cancel();
      return;
    }

    await Future.delayed(const Duration(seconds: 1));

    if (_isCallOrWalkieActive ||
        (Get.currentRoute.isNotEmpty && Get.currentRoute != Routes.Splash)) {
      _splashTimer?.cancel();
      return;
    }

    final token = Global.storageServices.getaccesstoken();
    final isRegistered = Global.storageServices.get(PrefConst.isRegistered);

    if (Utility.isNotNullEmptyOrFalse(token) && isRegistered == "true") {
      final locationReady = await _isLocationReady();

      if (_isCallOrWalkieActive ||
          (Get.currentRoute.isNotEmpty && Get.currentRoute != Routes.Splash)) {
        return;
      }

      if (locationReady) {
        Get.offAllNamed(Routes.Home_Screen);
      } else {
        Get.offAllNamed(Routes.permissionSetup);
      }
      return;
    }

    final introDone = await Global.storageServices.getBool(PrefConst.introStatus);

    if (introDone == true) {
      Get.offAllNamed(Routes.Login);
    } else {
      Get.offAllNamed(Routes.Intro);
    }
  }
  @override
  void onClose() {
    _splashTimer?.cancel();
    animationController.dispose();
    super.onClose();
  }
}
