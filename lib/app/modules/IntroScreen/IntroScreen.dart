import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/IntroScreen/Controller/IntroController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../gen/assets.gen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IntroController());
    const Color primaryPurple = Color(0xFF6A53E1);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (controller.index.value == 0) {
          Get.back();
        } else {
          controller.previous();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F5FD),
        body: Obx(() {
          final data = controller.introData[controller.index.value];

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  data['image'],
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),

              SafeArea(
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: reausabletext(
                      "Skip",
                      onTap: () {
                        Global.storageServices
                            .setBool(PrefConst.introStatus, true);
                        Get.offAllNamed(Routes.Login);
                      },
                      fontsize: 16.sp,
                      color: primaryPurple,
                      fontfamily: FontFamily.interSemiBold,
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF6F5FD),
                  padding: EdgeInsets.only(
                    left: 27.w,
                    right: 27.w,
                    top: 20.h,
                    bottom: 30.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Color(0xFFF6F5FD),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryPurple.withValues(alpha: 0.22),
                              blurRadius: 24,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: const Color(0xFF6A53E1).withValues(alpha: 0.10),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: data['icon'] is AssetGenImage
                            ? data['icon'].image(
                          width: 38.r,
                          height: 38.r,
                        )
                            : data['icon'] is FaIconData
                            ? SizedBox(
                          width: 38.r,
                          height: 38.r,
                          child: Center(
                            child: FaIcon(
                              data['icon'],
                              color: primaryPurple,
                              size: 28.r,
                            ),
                          ),
                        )
                            : Icon(
                          data['icon'],
                          color: primaryPurple,
                          size: 38.r,
                        ),
                      ),

                      15.h.verticalSpace,

                      reausabletext(
                        data['title'],
                        color: const Color(0xFF0F0A39),
                        fontsize: 25.sp,
                        fontfamily: FontFamily.interBold,
                      ),

                      5.h.verticalSpace,

                      reausabletext(
                        data['subtitle'],
                        color: const Color(0xFF5A5873),
                        fontfamily: FontFamily.interRegular,
                        fontsize: 14.sp,
                      ),

                      12.h.verticalSpace,

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (controller.index.value > 0)
                            GestureDetector(
                              onTap: controller.previous,
                              child: _backButton(primaryPurple),
                            )
                          else
                            SizedBox(width: 55.r),
                          GestureDetector(
                            onTap: controller.next,
                            child: _forwardButton(primaryPurple),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _backButton(Color primaryColor) {
    return Container(
      height: 50.r,
      width: 50.r,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(Icons.arrow_back, color: primaryColor, size: 24.r),
    );
  }

  Widget _forwardButton(Color primaryColor) {
    return Container(
      height: 55.r,
      width: 55.r,
      decoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24.r),
    );
  }
}