import 'package:fgtracker/app/modules/mediaStream/controller/call_controller.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../Core/constant/const_res.dart';
import '../../../Core/theme/appTheme.dart';
import '../../../Core/values/utility.dart';
import '../../../config/themes_data.dart';
import '../../../global_widget/common_widget.dart';

class AudiocallScreen extends StatelessWidget {
  AudiocallScreen({super.key, required this.controller});

  CallController controller;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 50.h),
      child: Column(
        children: [
          CircleAvatar(
            radius: 75.r,
            backgroundImage: NetworkImage(
                Utility.isNullEmptyOrFalse(controller.args['callerProfile'])
                    ? MyAppTheme.ProfilenotFoundImg
                    : ConstRes.aImageBaseUrl +
                        controller.args['callerProfile']),
          ),
          SizedBox(height: 7.h),
          reausabletext(controller.args["callerName"],
              fontsize: 28,
              fontfamily: FontFamily.interSemiBold,
              color: ToggleThemeData.white),
          Obx(() {
            return controller.formattedDuration == "00:00"
                ? reausabletext(
              "${controller.callStatus.value}...",
              color: ToggleThemeData.white,
              fontsize: 14,
            )
                : reausabletext(
              controller.formattedDuration,
              fontsize: 12,
              fontfamily: FontFamily.interMedium,
              color: ToggleThemeData.white,
            );
          })
        ],
      ),
    );
  }
}
