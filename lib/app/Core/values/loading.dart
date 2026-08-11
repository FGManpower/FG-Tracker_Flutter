
import 'package:fgtracker/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'Context_Utility.dart';
import 'colors.dart';

class Loading {
  showloading({BuildContext? context}) {
    return showDialog(
      barrierDismissible: false,
      context: context ?? ContextUtility.context!,
      builder: (ctx) => WillPopScope(
        onWillPop: () async => false,

        child: Center(
          child: SizedBox(
            height: 90.h,
            width: 90.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 90.h,
                  width: 90.w,
                  child: const CircularProgressIndicator(
                    backgroundColor: Color(0xffD0D0D0),
                    color: AppColors.darkBlue,
                    strokeWidth: 8,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(50.r),
                  child: Image.asset(
                    Assets.icons.appIcon.path,
                    width: 85.w,
                    height: 85.h,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  dismissloading({BuildContext? context}) {
    Navigator.pop(context ?? ContextUtility.context!);
  }
}


