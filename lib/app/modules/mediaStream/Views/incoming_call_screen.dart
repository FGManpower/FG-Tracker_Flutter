import 'dart:ui';
import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../gen/assets.gen.dart';
import '../../../Core/theme/appTheme.dart';
import '../../../Core/values/Curve/Call_Cipper.dart';
import '../controller/incoming_call_controller.dart';

class IncomingCallScreen extends GetView<IncomingCallController> {
  const IncomingCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50.h),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.images.registerationBg.path),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
            ),
            child: Column(
              children: [
                reausabletext("Call From",
                    fontsize: 18, fontfamily: FontFamily.interMedium),
                reausabletext(controller.call.callerName,
                    fontsize: 29, fontfamily: FontFamily.interSemiBold),
                SizedBox(height: 30.h),
                CircleAvatar(
                  radius: 75.r,
                  backgroundImage: NetworkImage(Utility.isNullEmptyOrFalse(controller.call.callerProfileImage)?MyAppTheme.ProfilenotFoundImg:ConstRes.aImageBaseUrl+controller.call.callerProfileImage),
                ),
                SizedBox(height: 7.h),
                reausabletext(
                    controller.call.isVideo
                        ? "Incoming Video Call…"
                        : "Incoming Audio Call…",
                    fontsize: 16,
                    fontfamily: FontFamily.interMedium),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: BottomFullArcClipper(),
              child: Container(
                height: 150.h,
                padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 30.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: controller.acceptCall,
                      child: CircleAvatar(
                        radius: 30.r,
                        backgroundColor: Colors.green,
                        child: const Icon(Icons.call,
                            color: Colors.white, size: 32),
                      ),
                    ),
                    InkWell(
                      onTap: controller.rejectCall,
                      child: CircleAvatar(
                        radius: 30.r,
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.call_end,
                            color: Colors.white, size: 32),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
