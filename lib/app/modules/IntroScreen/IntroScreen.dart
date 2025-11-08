import 'package:fgtracker/app/Core/constant/pref_res.dart';
import 'package:fgtracker/app/Core/values/Curve/Intro_CurvedDiagonalClipper.dart';
import 'package:fgtracker/app/Core/values/global.dart';
import 'package:fgtracker/app/config/themes_data.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/app/modules/IntroScreen/Controller/IntroController.dart';
import 'package:fgtracker/app/routes/app_pages.dart';

import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IntroController());

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (controller.index.value == 0) {
          Get.back();
        } else {
          // controller.previous();
        }
      },
      child: Scaffold(
        body: Obx(() {
          final data = controller.introData[controller.index.value];

          return Stack(
            children: [
              Container(
                height: 1.sh,
                width: 1.sw,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(data['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: reausabletext(
                      "Skip",
                      onTap: () {
                        Global.storageServices.setBool(PrefConst.introStatus, true);
                        Get.offAllNamed(Routes.Login);
                      },
                      fontsize: 16.sp,
                      color: ToggleThemeData.white,
                      fontfamily: FontFamily.interSemiBold,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipPath(
                  clipper: IntroCurvedDiagonalClipper(),
                  child: Container(
                    height: 0.35.sh,
                    width: double.infinity,
                    color: const Color(0xFF5045B9),
                    padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 30.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),

                        SizedBox(height: 20.h,),
                        reausabletext(
                          data['title'],
                          color: ToggleThemeData.white,
                          fontsize: 28.sp,
                          fontfamily: FontFamily.interBold,

                        ),
                        10.h.verticalSpace,
                        reausabletext(
                          data['subtitle'],
                          color: ToggleThemeData.white,
                          fontfamily: FontFamily.interRegular,
                          fontsize: 17.sp,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (controller.index.value > 0)
                              GestureDetector(
                                onTap: controller.previous,
                                child: _circleButton(Icons.arrow_back),
                              )
                            else
                              SizedBox(width: 35.r),
                            GestureDetector(
                              onTap: controller.next,
                              child: _circleButton(Icons.arrow_forward_rounded),
                            ),
                          ],
                        ),
                        20.h.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.introData.length,
                                (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              height: 8.r,
                              width: controller.index.value == i ? 24.w : 8.w,
                              decoration: BoxDecoration(
                                color: controller.index.value == i
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _circleButton(IconData icon) {
    return Container(
      height: 35.r,
      width: 35.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5.w),
      ),
      child: Icon(icon, color: Colors.white, size: 22.r),
    );
  }
}


