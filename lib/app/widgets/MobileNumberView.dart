// ignore_for_file: unused_import

import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MobileNumberController extends GetxController {
  var obscureNumber = true.obs;

  void toggleObscure() {
    obscureNumber.value = !obscureNumber.value;
  }
}

class MobileNumberView extends StatelessWidget {
  final String mobileNumber;
  final MobileNumberController controller = MobileNumberController();

  MobileNumberView({super.key, required this.mobileNumber});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String displayNumber;
      if (controller.obscureNumber.value) {
        if (mobileNumber.length >= 2) {
          displayNumber = '••••••${mobileNumber.substring(mobileNumber.length - 4)}';
        } else {
          displayNumber = '••••••';
        }
      } else {
        displayNumber = mobileNumber;
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            displayNumber,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black.withValues(alpha: 0.6),
              fontFamily: FontFamily.interRegular,
            ),
          ),
          SizedBox(width: 8.w),
          // GestureDetector(
          //   onTap: controller.toggleObscure,
          //   child: Padding(
          //     padding: EdgeInsets.only(top: 2),
          //     child: Obx(() => Icon(
          //       controller.obscureNumber.value
          //           ? Icons.visibility_off
          //           : Icons.visibility,
          //       size: 20.sp,
          //       color: ToggleThemeData.darkPurple,
          //     )),
          //   ),
          // ),
        ],
      );
    });
  }
}