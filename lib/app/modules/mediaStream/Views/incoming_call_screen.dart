import 'dart:ui';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../gen/assets.gen.dart';
import '../../../Core/theme/appTheme.dart';
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
                  backgroundImage: NetworkImage(MyAppTheme.notFoundImg),
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

          // ------------------- BOTTOM CURVED UI -------------------
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120.h,
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(120.r),
                  topRight: Radius.circular(120.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              // color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      controller.acceptCall();
                    },
                    child: Container(
                      height: 80.r,
                      width: 80.r,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child:
                          const Icon(Icons.call, color: Colors.white, size: 32),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      controller.rejectCall();
                    },
                    child: Container(
                      height: 80.r,
                      width: 80.r,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.call_end,
                          color: Colors.white, size: 32),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurBackground(String imgUrl) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                imgUrl.isNotEmpty ? imgUrl : MyAppTheme.ProfilenotFoundImg,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.black.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(IncomingCallController c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            FloatingActionButton(
              heroTag: "reject_btn",
              backgroundColor: Colors.red,
              onPressed: c.rejectCall,
              child: const Icon(Icons.call_end, size: 32),
            ),
            const SizedBox(height: 10),
            const Text(
              "Decline",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        Column(
          children: [
            FloatingActionButton(
              heroTag: "accept_btn",
              backgroundColor: Colors.green,
              onPressed: c.acceptCall,
              child: const Icon(Icons.call, size: 32),
            ),
            const SizedBox(height: 10),
            const Text(
              "Accept",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Move from bottom-left up to the top-left corner
    path.moveTo(0, size.height);

    // Left vertical edge up
    path.lineTo(0, size.height * 0.35);

    // FULL smooth semicircle
    path.quadraticBezierTo(
      size.width * 0.5, // mid X
      -size.height * 0.4, // high arc (bigger = more curve)
      size.width, size.height * 0.35,
    );

    // Right vertical edge down
    path.lineTo(size.width, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
