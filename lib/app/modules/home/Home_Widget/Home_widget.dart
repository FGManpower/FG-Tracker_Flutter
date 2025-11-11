import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Core/theme/appTheme.dart';
import '../../../config/themes_data.dart';
import '../Controller/home_controller.dart';

Widget headerUi(HomeController controller) {
  return
    Obx(() =>   Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              reausabletext("Hello ${controller.userData.value.name ?? ""}",
                  fontfamily: FontFamily.interSemiBold, fontsize: 19),
              reausabletext("It’s good to see you again 👋",
                  fontfamily: FontFamily.interRegular, fontsize: 12),
            ],
          ),
        ),


        Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: IconButton(
            icon: CircleAvatar(
              radius: 27.r,
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(
                Utility.isNotNullEmptyOrFalse(
                    controller.userData.value.profileImage)
                    ? "${ConstRes.aImageBaseUrl}${controller.userData.value.profileImage}"
                    : MyAppTheme.ProfilenotFoundImg,
              ),
              child: controller.userData.value.profileImage == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            onPressed: () {},
          ),
        )
      ],
    ));

}

Widget ReusablelistItem(
    {String? name,
    required String imagename,
    void Function()? func,
    int height = 25,
    int width = 25}) {
  return Padding(
    padding: EdgeInsets.only(top: 5.h),
    child: InkWell(
        onTap: func,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 25.w),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: ToggleThemeData.darkPurple,
                    radius: 21.r,
                    child: SvgPicture.asset(
                      imagename,
                      height: height.h,
                      width: width.w,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 20.w,
                  ),
                  reausabletext(
                    align: TextAlign.center,
                    name.toString(),
                    fontfamily: FontFamily.interMedium,
                    fontsize: 16,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5.h,
            ),
            Divider(
              color: Colors.black12,
              thickness: 2,
            ),
          ],
        )),
  );
}

Widget Social_Icon({required String imagename, required String url}) {
  return Padding(
    padding: EdgeInsets.only(right: 7.w),
    child: CircleAvatar(
        radius: 17.r,
        backgroundColor: ToggleThemeData.Appcolor,
        child: Center(
          child: InkWell(
            onTap: () {
              launch(url);
            },
            child: SvgPicture.asset(
              imagename,
              height: 20.h,
              width: 20.w,
              color: Colors.white,
            ),
          ),
        )),
  );
}
