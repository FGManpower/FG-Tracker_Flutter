import 'package:fgtracker/app/Core/constant/const_res.dart';
import 'package:fgtracker/app/Core/theme/appTheme.dart';
import 'package:fgtracker/app/Core/values/utility.dart';
import 'package:fgtracker/app/Model/member_live_status.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:fgtracker/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

Widget SkeletonMember() {
  var skeletonMembers = List<UserMemberData>.generate(
    12,
    (index) => UserMemberData(
      userId: index,
      name: 'Member Name',
      mobileNo: '0000000000',
      profileImage: '',
      isOnline: 1,
      locationSharing: 1,
    ),
  );
  return Skeletonizer(
    enabled: true,
    child: ListView.builder(
      padding: EdgeInsets.fromLTRB(
        18.w,
        0,
        18.w,
        20.h,
      ),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: skeletonMembers.length,
      itemBuilder: (context, index) {
        return memberCard(
          skeletonMembers[index],
        );
      },
    ),
  );
}

Widget memberCard(UserMemberData member) {
  final String name = member.name?.trim().isNotEmpty == true
      ? member.name!.trim()
      : 'Unknown Member';

  final bool isOnline = member.isOnline == 1;

  return Container(
    margin: EdgeInsets.only(bottom: 5.h),
    padding: EdgeInsets.symmetric(
      horizontal: 10.w,
      vertical: 7.h,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.r),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 9,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 30.sp,
              backgroundImage: NetworkImage(
                  Utility.isNullEmptyOrFalse(member.profileImage)
                      ? MyAppTheme.notFoundImg
                      : ConstRes.aImageBaseUrl +
                          member.profileImage.toString()),
            ),
            Positioned(
              right: 0,
              bottom: 1.h,
              child: Container(
                width: 19.w,
                height: 19.w,
                decoration: BoxDecoration(
                  color: isOnline ? const Color(0xFF08C887) : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              reausabletext(
                name,
                fontsize: 14.sp,
                fontfamily: FontFamily.interBold,
              ),
              SizedBox(height: 2.h),
              reausabletext(
                'FG Manpower Development',
                fontsize: 10.sp,
                fontfamily: FontFamily.interSemiBold,
                color: const Color(0xFF6255E7),
              ),
              SizedBox(height: 4.h),
              reausabletext(
                isOnline ? 'Online' : 'Offline',
                fontsize: 12.sp,
                fontfamily: FontFamily.interRegular,
                color: const Color(0xFF68729C),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
