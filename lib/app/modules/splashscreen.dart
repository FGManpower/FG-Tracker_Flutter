import 'dart:async';

import 'package:fgtracker/app/Core/util/Media_query_extension.dart';
import 'package:fgtracker/app/Core/util/http/Constant.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/modules/AppUpdate/Controller/UpdateCubit/update_cubit.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Core/values/global.dart';
import 'AppUpdate/Views/ShoreBird_AppUpdate_Screen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({Key? key}) : super(key: key);

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final UpdateCubit updateCubit = UpdateCubit();

  @override
  void initState() {
    super.initState();
    checkAppUpdates();
  }

  Future<void> checkAppUpdates() async {
    updateCubit.checkForUpdate();
    final isUpdateRequired = await updateCubit.checkForUpdate();

    if (!isUpdateRequired) {
      checkLoginStatus();
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ShorebirdAppUpdateScreen(),
          ),
        );
      });
    }
  }

  void checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (Utility.isNotNullEmptyOrFalse(Global.storageServices.getaccesstoken()) &&
        Utility.isNotNullEmptyOrFalse(
            Global.storageServices.get(Constant.isRegistered))) {
      Get.offAllNamed(Routes.Home_Screen);
    } else {
      Get.offAllNamed(Routes.Login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        child: Center(
          child: Stack(
            children: [
              Center(
                child: Image.asset(
                  Assets.icons.appIcon.path,
                  height: context.blockHeight * 55,
                  width: context.blockWidth * 55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
