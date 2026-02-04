import 'dart:ui';

import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/mediaStream/Views/AudioCall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../gen/fonts.gen.dart';
import '../../../Core/values/Curve/Call_Cipper.dart';
import '../controller/call_controller.dart';

class CallScreen extends StatelessWidget {
  final controller = Get.put(CallController());

  CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallController>(
      builder: (c) {
        return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                Positioned.fill(
                  child: c.is_video
                      ? RTCVideoView(
                          c.remoteRenderer,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      : Center(
                          child: AudiocallScreen(controller: controller),
                        ),
                ),
                Positioned(
                  top: 50.h,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0.r),
                      bottomRight: Radius.circular(0.r),
                    ),
                    child: c.is_video
                        ? BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                            child: Container(
                              height: 100.h,
                              color: Colors.white.withOpacity(0.22),
                              padding: EdgeInsets.symmetric(vertical: 7.h),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  reausabletext("Call From",
                                      fontsize: 17,
                                      fontfamily: FontFamily.interMedium,
                                      color: ToggleThemeData.white),
                                  reausabletext(controller.args["callerName"],
                                      fontsize: 28,
                                      fontfamily: FontFamily.interSemiBold,
                                      color: ToggleThemeData.white),
                                  Utility.isNullEmptyOrFalse(controller.formattedDuration)
                                      ? reausabletext(
                                      "Ringing..",
                                      fontsize: 12,
                                      fontfamily: FontFamily.interMedium,
                                      color: ToggleThemeData.white)
                                      : reausabletext(
                                          controller.formattedDuration,
                                          fontsize: 12,
                                          fontfamily: FontFamily.interMedium,
                                          color: ToggleThemeData.white),

                                ],
                              ),
                            ),
                          )
                        : SizedBox(),
                  ),
                ),
                if (c.is_video == true)
                  Positioned(
                      left: 20.w,
                      bottom: 140.h,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7.r),
                        child: SizedBox(
                          height: 150.h,
                          width: 120.w,
                          child: RTCVideoView(
                            c.localRenderer,
                            mirror: c.isFrontCamera,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                          ),
                        ),
                      )),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: BottomFullArcClipper(),
                    child: Container(
                      height: 120.h,
                      padding: EdgeInsets.symmetric(
                          horizontal: 60.w, vertical: 30.h),
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
                          IconButton(
                            icon: reausableIcon(
                                icon: c.isAudioOn ? Icons.mic : Icons.mic_off,
                                color: Color(0xff6E6E6E),
                                size: 35),
                            onPressed: c.toggleMic,
                          ),
                          InkWell(
                            onTap: c.endCall,
                            child: CircleAvatar(
                              radius: 30.r,
                              backgroundColor: Colors.red,
                              child: reausableIcon(
                                  icon: Icons.call_end,
                                  color: Colors.white,
                                  size: 32),
                            ),
                          ),
                          if (c.is_video == true)
                            IconButton(
                              icon: reausableIcon(
                                  icon: Icons.cameraswitch,
                                  color: Color(0xff6E6E6E),
                                  size: 35),
                              onPressed: c.switchCamera,
                            ),
                          if (c.is_video == true)
                            IconButton(
                              icon: reausableIcon(
                                  icon: c.isVideoOn
                                      ? Icons.videocam
                                      : Icons.videocam_off,
                                  color: Color(0xff6E6E6E),
                                  size: 35),
                              onPressed: c.toggleCamera,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ));
      },
    );
  }
}
