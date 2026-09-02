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
import '../../../routes/app_pages.dart';
import '../Controller/home_controller.dart';

Widget headerUi(HomeController controller) {
  return Obx(() => Row(
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
            padding: EdgeInsets.only(right: 0.w),
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
              onPressed: () {
                Get.toNamed(Routes.Register, arguments: {
                  "type": "Update",
                  'userData': controller.userData.value
                });
              },
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

class GroupRow extends StatelessWidget {
  final String title;
  final String value;
  final bool showDivider;

  const GroupRow({
    Key? key,
    required this.title,
    required this.value,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              reausabletext(
                title,
                fontfamily: FontFamily.interRegular,
                fontsize: 9,
                // maxline: 1,
                // textoverflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 7.h),
              reausabletext(
              //   widths: 52,
                value,
                fontfamily: FontFamily.interSemiBold,
                fontsize: 10,
                color: const Color(0xff5045B9),
                maxline: 1,
                textoverflow: TextOverflow.ellipsis,

              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Container(
              height: 35.h,
              width: 1.w,
              color: const Color(0xff5045B9),
            ),
          ),
      ],
    );
  }
}

class MapLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6B4DFF),
        ),
      ),
    );
  }
}

class MapControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const MapControlBtn({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(7.w),
          child: Icon(
            icon,
            size: 18.sp,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

class MapFilterBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const MapFilterBadge({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            if (icon != Icons.keyboard_arrow_down) ...[
              Icon(
                icon,
                size: 14.sp,
                color: const Color(0xFF6B4DFF),
              ),
              SizedBox(width: 4.w),
            ],
            reausabletext(
              text,
              fontsize: 11.sp,
              color: Colors.black87,
            ),
            if (icon == Icons.keyboard_arrow_down) ...[
              SizedBox(width: 4.w),
              Icon(
                icon,
                size: 16.sp,
                color: Colors.black87,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
